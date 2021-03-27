const { use, expect } = require('chai');
const { solidity } = require('ethereum-waffle');

const Tracking = artifacts.require('Tracking');

const Reverter = require('./helpers/reverter');

use(solidity);
use(require('chai-as-promised')).should();

contract('Traking', (accounts) => {
  const reverter = new Reverter(web3);

  const OLEG = accounts[1];
  const IVAN = accounts[2];

  let tracking;

  before(async () => {
    tracking = await Tracking.new('Samsung', 'Seoul, South Korea', 'Samsung Group is a South Korean group of ' +
      'companies, one of the largest chaebols, founded in 1938. ');

    await reverter.snapshot();
  });

  afterEach(async () => {
    await reverter.revert();
  });

  describe('check point logic', async () => {
    it('should create points', async () => {
      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG);
      await tracking.createPoint('Some name2', 'Some country2', 'Some city2', 'Some address2', IVAN);

      const point0 = await tracking.points(0);
      const point1 = await tracking.points(1);

      assert.equal(point0.pointOwner, OLEG);
      assert.equal(point1.pointOwner, IVAN);
    });

    it('should increase total point number', async () => {
      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG);
      assert.equal((await tracking.pointsTotal()).toNumber(), 1);

      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG);
      assert.equal((await tracking.pointsTotal()).toNumber(), 2);
    });

    it('should revert if point created not from owner', async () => {
      await expect(tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG,
        { from: OLEG })).to.be.revertedWith('Ownable: caller is not the owner');
    });
    it('should transfer point ownership', async () => {
      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG);
      await tracking.transferPointOwnership(0, IVAN);

      const point0 = await tracking.points(0);
      assert.equal(point0.pointOwner, IVAN);
    });
    it('should revert if point not found or sender not a OWNER', async () => {
      await expect(tracking.transferPointOwnership(0, IVAN)).to.be.revertedWith('E-84');

      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG);
      await expect(tracking.transferPointOwnership(0, IVAN, { from: OLEG }))
        .to.be.revertedWith('Ownable: caller is not the owner');
    });
  });

  describe('check point transfer logic', async () => {
    const types = {
      manufacture: 0,
      transport: 1,
      realization: 2,
    };

    const IPFSLink = ['https://ipfs.io/ipfs/QmS4ustL54uo8F', 'https://ipfs.io/ipfs/yvMcX9Ba8nUH4uVv'];
    const batchNum = ['0000101', '0000102'];

    beforeEach(async () => {
      await tracking.createPoint('Some name1', 'Some country1', 'Some city2', 'Some address2', OLEG); // Point 0
      await tracking.createPoint('Some name2', 'Some country2', 'Some city2', 'Some address2', IVAN); // Point 1
    });

    it('should create point transfer', async () => {
      await tracking.createProductTransfer(0, IPFSLink[0], types.manufacture, batchNum[0], { from: OLEG }); // PT 0

      const pt0 = await tracking.productTransfers(0);
      assert.equal(pt0.pointId, 0);
      assert.equal(pt0.link, IPFSLink[0]);
      assert.equal(pt0.transferType, types.manufacture);
    });

    it('should write batch number to mapping', async () => {
      await tracking.createProductTransfer(0, IPFSLink[0], types.manufacture, batchNum[0], { from: OLEG }); // PT 0
      await tracking.createProductTransfer(0, IPFSLink[1], types.transport, batchNum[0], { from: OLEG }); // PT 1
      await tracking.createProductTransfer(1, IPFSLink[1], types.realization, batchNum[1], { from: IVAN }); // PT 2

      assert.equal(await tracking.batchNumberToProductTransfers(batchNum[0], 0), 0);
      assert.equal(await tracking.batchNumberToProductTransfers(batchNum[0], 1), 1);
      assert.equal(await tracking.batchNumberToProductTransfers(batchNum[1], 0), 2);
    });

    it('should increase total product transfer number', async () => {
      await tracking.createProductTransfer(0, IPFSLink[0], types.manufacture, batchNum[0], { from: OLEG }); // PT 0
      assert.equal((await tracking.productTransfersTotal()).toNumber(), 1);

      await tracking.createProductTransfer(0, IPFSLink[0], types.manufacture, batchNum[0], { from: OLEG }); // PT 0
      assert.equal((await tracking.productTransfersTotal()).toNumber(), 2);
    });

    it('should reverted when invalid point ID', async () => {
      await expect(tracking.createProductTransfer(123, IPFSLink[0], types.manufacture, batchNum[0], { from: OLEG }))
        .to.be.revertedWith('E-87');
    });

    it('should reverted when caller not a point owner', async () => {
      await expect(tracking.createProductTransfer(0, IPFSLink[0], types.manufacture, batchNum[0]))
        .to.be.revertedWith('E-88');
    });
  });
});
