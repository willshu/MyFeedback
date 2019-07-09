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
    mapping(address => bool) public hasReviewed;
    
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
            require(_technical <= 5 && _communication <= 5 && _overall <= 5, 'Score must be between 1 and 5');
            reviewer[msg.sender] = Review(_technical, _communication, _overall, _comment_communication, _comment_technical, _comment_overall, true);
            reviewerAccts.push(msg.sender) -1;
            hasReviewed[msg.sender] = true;
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