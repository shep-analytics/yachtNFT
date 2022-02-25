const DogeBall = artifacts.require("DogeBall");

module.exports = function(deployer) {
  deployer.deploy(DogeBall);
};
