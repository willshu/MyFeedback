var MyFeedback  = artifacts.require("./MyFeedback.sol");

web3.eth.getAccounts().then(function(acc) {accounts = acc});

contract("MyFeedback", function(accounts) {
    var feedbackInstance;

  
  it("initializes with owner as Will Shu", function() {
    return MyFeedback.deployed().then(function(instance) {
    return instance.name();
    }).then(function(name) {
        assert.equal(name, "Will Shu");
    });
  });


  it("allows a reviewer to leave a review", function() {
    return MyFeedback.deployed().then(function(instance) {
      feedbackInstance = instance;
      return feedbackInstance.setReview(10, "great", 10, "great", 10, "great", { from: accounts[1] });
    }).then(function(receipt) {
      assert.equal(receipt.logs.length, 1, "an event was triggered");
      assert.equal(receipt.logs[0].event, "reviewEvent", "the event type is correct");
    })
  });

  it("throws an exception for 2nd review", function() {
    return MyFeedback.deployed().then(function(instance) {
      feedbackInstance = instance;
      return feedbackInstance.setReview(10, "great", 10, "great", 10, "great", { from: accounts[1] });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
    })
  });

  it("allows the owner to retrieve the review", function(){
    return MyFeedback.deployed().then(function(instance) {
    feedbackInstance = instance;
    return feedbackInstance.getReview(0, {from: accounts[0]});
    }).then(function(result){
        assert.equal(result['0'].toString(), 10)
    })

  });

})
  