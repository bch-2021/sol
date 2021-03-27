class Reverter {
  constructor(web3) {
    this.web3 = web3;
    this.snapshotId = 0;
  }

  revert() {
    return new Promise((resolve, reject) => {
      this.web3.currentProvider.send({
        jsonrpc: '2.0',
        method: 'evm_revert',
        id: new Date().getTime(),
        params: [this.snapshotId],
      }, (err) => {
        if (err) return reject(err);
        return resolve(this.snapshot());
      });
    });
  }

  snapshot() {
    return new Promise((resolve, reject) => {
      this.web3.currentProvider.send({
        jsonrpc: '2.0',
        method: 'evm_snapshot',
        id: new Date().getTime(),
      }, (err, result) => {
        if (err) return reject(err);
        this.snapshotId = this.web3.utils.toDecimal(result.result);
        return resolve(this.snapshotId);
      });
    });
  }
}

module.exports = Reverter;
