var MyFeedback = artifacts.require("./MyFeedback.sol");
var name  = "Will Shu"
module.exports = function(deployer) {
  deployer.deploy(MyFeedback, name);
};
