const Tracking = artifacts.require('Tracking');

module.exports = (deployer) => {
  deployer.deploy(Tracking, 'Samsung', 'Seoul, South Korea', 'Samsung Group is a South Korean group of companies, '
    + 'one of the largest chaebols, founded in 1938.', [0, 1, 2]);
};
