/*
MyFeedback.sol:

This smart contract is deployed by an individual who is requesting feedback for a performance review. 
Once deployed by the user, only this user can retrieve and read feedback given by others. 
Additionally, only users other than the owner can leave feedback.

Front end:

This is where I need help. I need a very simple front end which connects to a ganache instance via  metamask and  has the following capabilities. 

- any user can deploy an instance of the contract to the blockchain. this account  will be the owner.
- once deployed,  the contract  instance name can be selected in UI
-  if the account  is the same as the account that  deployed the  contract, selecting the contract will view the feedback.
- if the account is different  than the account that deployed  the contract, selecting the contract will display a feedback form.
-  include transaction link and records for any contract calls  or creation
*/

pragma solidity 0.5.8;

contract MyFeedback {
    
    address public owner;
    string public name;
    
    constructor (string memory _name) public {
        owner = msg.sender;
        name = _name;
    }
    
    struct Review {
        uint technicalScore;
        uint communicationScore;
        uint overallScore;
        string comment_communication;
        string comment_technical;
        string comment_overall;
        bool alreadyReviewed;
    }
    
    mapping  (address => Review) reviewer;
    address [] public reviewerAccts;
    
    modifier onlyOwner {
        require(msg.sender == owner, 'Only the owner can call this function');
        _;
    }
    
    modifier notOwner {
        require(msg.sender != owner, 'Only a reviewer can call this function');
        _;
    }    
    
    modifier notAlreadyReviewed {
        require(reviewer[msg.sender].alreadyReviewed != true, 'Cannot review more than once');
        _;
    }
    
    
    event reviewEvent(address reviewer, uint overallScore);
    
    function setReview(uint _technical, string memory _comment_technical,
        uint _communication, string memory _comment_communication,  
        uint _overall, string memory _comment_overall) notAlreadyReviewed notOwner public {
            require(_technical <= 10 && _communication <= 10 && _overall <= 10, 'Score must be between 1 and 10');
            reviewer[msg.sender] = Review(_technical, _communication, _overall, _comment_communication, _comment_technical, _comment_overall, true);
            reviewerAccts.push(msg.sender) -1;
            emit reviewEvent(msg.sender, reviewer[msg.sender].overallScore);
        }
    
    function getReview(uint index) onlyOwner public view returns(uint, uint, uint, string memory, string memory, string  memory) {
        return (reviewer[reviewerAccts[index]].technicalScore, 
        reviewer[reviewerAccts[index]].communicationScore, 
        reviewer[reviewerAccts[index]].overallScore,
        reviewer[reviewerAccts[index]].comment_technical,
        reviewer[reviewerAccts[index]].comment_communication,
        reviewer[reviewerAccts[index]].comment_overall);
    }
    
    function totalReviewers() public view returns (uint){
        return reviewerAccts.length;
    }
    
}