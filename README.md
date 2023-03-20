# Eth2 Node
Eth2 のフルノードを建てるサンプルです。
Consensus に Prysm を使用し、Execution に Geth を使用します。
GCPでVMを新規に作成し、そこにノードを起動することができます。

## ファイアウォールの設定を確認してください。
デフォルトでは、RPCポートをすべてのIPに対して解放します。
GCPのネットワーク設定のファイアウォールルールで、間違ってポートを解放していないか確認してください。
基本的には、サブネット内からは自由に通信できて、外からは通信できないようにすると便利です。

geth用に、TCP/30303、UDP/30303 を解放してください。（VMに'geth'というネットワークを付けてあるので、ファイアウォールルールで使うと良いです）
Prysm用に、TCP/13000、UDP/12000 を解放してください。（VMに'prysm'というネットワークを付けてあるので、ファイアウォールルールで使うと良いです）

# 1. VMの起動と設定
VMのサービスアカウントの設定が必要です。
env というファイルを gcp_setup ディレクトリ内に用意して、ファイル内で使いたいサービスアカウントの名前を設定してください。

```shell
SERVICE_ACCOUNT=xxxxxxx
```

その後以下のステップで起動を行ってください。

```shell
# VMを起動します。
# マシンタイプを変更する場合は、Makefileを直接編集してから make を実行してください。
# もしくは `make MACHINE=n2-standard-4` のように指定することも可能です。
# 
# SSDの数を変更する場合は、Makefileを直接編集する必要があります。
# VM起動時の `--local-ssd` の引数の数でSSDの数が決まります。
cd gcp_setup && make

# 上記のコマンドを使わずに、Makefile.testnet というファイルを使って以下のように起動することもできます。
# こちらのファイルでは、SSDの数やマシンタイプが変更済みです。
cd gcp_setup && make -f Makefile.testnet

# VMが立ち上がったらログインして、再度このレポジトリをクローンしてください
...

# VMのSSDを設定します。
# SSDの数を変更している場合は、再度 merge-ssd で実行されるコマンドをSSDの数に応じて編集してください。
cd gcp_setup && make ssd

# VM起動時に、Makefile.testnetを使った場合は、以下を実行します。
cd gcp_setup && make -f Makefile.testnet ssd

# SSDをテストしたい場合は以下のコマンドでできます。(SSD0のみのテストです。必要に応じて変更してください）
make test-ssd-iops
make test-ssd-through-pu

# Swap領域をセットアップすることをお勧めします（GCPのVMにはデフォルトでスワップ領域が0です）
# スワップがなくても動きます。
# Swap作成時に真面目に dd コマンドを使うため少し時間がかかります。
# dd を使わずにショートカットをしてスワップを確保する方法もありますが、問題を引き起こすことがあるので、必ずddコマンドを使いましょう。
make swap

# スワップがセットアップされたことの確認
make check-swap

# NTPの状態を一応確認しておいてください。Google のNTPのみが指定されている状態が正しいです。
chronyc sources
```

# 2. mev-boost の起動
`mev-boost` というディレクトリ内に、`env`というファイルを作り、ネットワークを指定してください。
デフォルトではmainnetです。
mev-boostが起動していないと、Prysmの起動が失敗します。（直したかも）

```shell
NETWORK=goerli
```

```shell
# Goのインストールと、mev-boostのインストールを行います。
make install

# mev-boostをサービスとして登録して起動します。
make run

# サービスの状態の確認
make status

# ログは、/var/log/beacon/beacon.log で見れます。
# 日時で30日分ログローテーションされます。
tail -f /var/log/geth/geth.log

# クライアントの更新時
make update
```

設定がうまく行っていれば、mev-boostに定期的にリクエストが来ているのを確認できます。

# 3. Execution-layer client (geth) のインストールと起動
```shell
cd geth-post-merge

# geth をインストールします。
make install

# JWTシークレットの生成
make jwt

# gethのクライアントをサービスとして登録して起動します。
# geth.service を編集してノードの設定を必要に応じて変更してください。
# デフォルトでは、すべてのノードからのRPCリクエストを受け付けるようになっています。
# ファイアウォールルールで不用意にポートを解放しないように注意してください。
make

# サービスの状態の確認
make status

# ログは、/var/log/geth/geth.log で見れます。
# 日時で30日分ログローテーションされます。
tail -f /var/log/geth/geth.log

# 同期状況は、attachして確認するのが簡単です。同期が終わるまで待ちます。
# syncing: false になるまで待ちましょう。
make attach
>eth

# gethのアップデートは簡単です。定期的にアップデートしましょう。
make update
```

# 4. Consensus-layer client (Prysm) のインストールと起動
かならず、先ほど立ち上げた geth をエンドポイントに使用し、Executionのエンドポイントに Infura などを指定するのはおやめください。The Merge 後に動かなくなります。

`geth-post-merge`というディレクトリ内に、`env`というファイルを作り、設定をしてください。
例えば以下のようにします。既にノードを運用している場合は、そのエンドポイントをcheckpoint syncに指定してください。
既存のノードがないがcheckpoint syncを行なって高速に同期したい場合は、Infuraのエンドポイントを指定することができます。
Goerliの場合は、公式のチェックポイントがデフォルトで指定されているので指定する必要はないです。

```shell
NETWORK=mainnet
FEE_RECIPIENT=0x***********************
CHECKPOINT=*****************
```

```shell
NETWORK=goerli
FEE_RECIPIENT=0x******************************
```

```shell
# Prysmのインストール
cd prysm-post-merge
make install

# Prysmのクライアントをサービスとして登録して起動します。
# 初回の起動は以下のコマンドを使ってください。
# かならず、CHECKPOINTに、ご自分の Infura のノードか、自分の別のノードを指定してください。
make run-checkpoint

# もしgenesisから完全に同期する場合は、beacon.service に、--genesis-state=${GENESIS_DIR}/genesis.ssz  を追加して
# 以下のコマンドを実行してください。ものすごい時間がかかります。
#
# make genesis
# make

# サービスの状態の確認
make status

# ログは、/var/log/beacon/beacon.log で見れます。
# 日時で30日分ログローテーションされます。
# ディレクトリ名が、prysm ではなく、beaconになっているのは、prysmにはbeacon以外の機能もあるからです。
tail -f /var/log/geth/geth.log

# 同期後に、もう一度以下のコマンドで systemd を上書きし、checkpoint syncの設定を無効化することをお勧めします。
make run

# MEV-boost を使わない場合はこちらで、起動してください。
# make run-nomevboost

# クライアントの更新は以下のように行います。
make update

```




