const { use } = require('chai');
const { solidity } = require('ethereum-waffle');

const Tracking = artifacts.require('Tracking');
const Reverter = require('./helpers/reverter');
const Helper = require('./helpers/helper');

use(solidity);
use(require('chai-as-promised')).should();

contract('Transaction statistic', (accounts) => {
  const reverter = new Reverter(web3);
  const h = new Helper();

  const OLEG = accounts[1];

  const gasUsageResults = [];
  const gasPrice = 150;
  const ethPrice = 1500;

  let tracking;

  before(async () => {
    tracking = await Tracking.new('Samsung', 'Seoul, South Korea', 'Samsung Group is a South Korean group of '
      + 'companies, one of the largest chaebols, founded in 1938.', [0, 1, 2]);

    const receipt = await web3.eth.getTransactionReceipt(tracking.transactionHash);
    gasUsageResults.push({ name: 'deploy()', gasUsage: receipt.gasUsed });

    await reverter.snapshot();
  });

  afterEach(async () => {
    await reverter.revert();
  });

  describe('Form transaction statistic', async () => {
    it('createPoint', async () => {
      await tracking.createPoint('Some name1', 'Some address2', OLEG).then((res) => {
        gasUsageResults.push({ name: 'createPoint()', gasUsage: res.receipt.gasUsed });
      });
    });
    it('createProductTransfer', async () => {
      await tracking.createPoint('Some name1', 'Some address2', OLEG);

      await tracking.createProductTransfer(0, 'Link', 0, '0000', { from: OLEG }).then((res) => {
        gasUsageResults.push({ name: 'createProductTransfer()', gasUsage: res.receipt.gasUsed });
      });
    });
  });

  describe('form result', async () => {
    it('form result', async () => {
      console.log('EthPrice - ', ethPrice);
      console.log('GasPrice - ', gasPrice);
      console.log(h.createRow(['Name', 'Gas usage', 'ETH', 'USD'], 25));
      gasUsageResults.forEach((obj) => {
        const TransactionETH = (gasPrice * obj.gasUsage) / 10 ** 9;
        const TransactionUSD = TransactionETH * ethPrice;
        console.log(h.createRow([obj.name, obj.gasUsage, TransactionETH, TransactionUSD], 25));
      });
    });
  });
});
