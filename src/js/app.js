App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("MyFeedback.json", function(feedback) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.MyFeedback = TruffleContract(feedback);
      // Connect provider to interact with contract
      App.contracts.MyFeedback.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.MyFeedback.deployed().then(function(instance) {
      instance.reviewEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new review is recorded
        App.render();
      });
    });
  },

  render: function() {
    var feedbackInstance;
    //var loader = $("#loader");
    var content = $("#content");

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });
    // Check if user is the owner
    App.contracts.MyFeedback.deployed().then(function(instance) {
      feedbackInstance = instance;  
      return feedbackInstance.owner();
    }).then(function(isOwner) {
      if(isOwner == App.account){
        $('form').hide();
        content.show()
      }
    // Check if reviewer has already reviewed 
      return feedbackInstance.hasReviewed(App.account);
        }).then(function(hasReviewed) {
          if(hasReviewed) {
            $('form').hide();
          }
          content.show();
        }).catch(function(error) {
          console.warn(error); 
    });
  },

  submitReview: function() {
    var score_technical = $('#score_technical').val();
    var comment_technical = $('#comment_technical').val();
    var score_communication = $('#score_communication').val();
    var comment_communication = $('#comment_communication').val();
    var score_overall = $('#score_overall').val();
    var comment_overall = $('#comment_overall').val();

    App.contracts.MyFeedback.deployed().then(function(instance) {
      return instance.setReview(score_technical, comment_technical, score_communication, comment_communication,
        score_overall, comment_overall, { from: App.account });
    }).then(function(result) {
      // Wait for review
      $("#content").hide();
      //$("#loader").show();
    }).catch(function(err) {
      console.error(err);
    });
    //reset the form
    document.getElementById("myForm").reset()
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});