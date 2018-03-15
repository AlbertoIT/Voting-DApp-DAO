/**
  * The Movement
  * Decentralized Autonomous Organization
  */
  
pragma solidity ^0.4.18;

contract Token {
    function balanceOf(address addr) returns (uint);
}

contract CheckTokenBalance {
  Token myToken;
    function CheckTokenBalance(address addressToken) {
        myToken = Token(addressToken);
    }
  function setToken(address tokenAddress) {
    myToken = Token(tokenAddress);
  }

  function getTokenBalanceOf(address owner) constant returns (uint) {
    return myToken.balanceOf(owner)/(10 ** 18);
  }
}

contract MovementVoting {
    mapping(address => int256) public votes;
    address[] public voters;
    uint256 public endBlock;
	address public admin;
	
	uint minTokenAmountToVote=400;
	//string urlVotingDetails;
	CheckTokenBalance checker;
	
    event onVote(address indexed voter, int256 indexed proposalId);
    event onUnVote(address indexed voter, int256 indexed proposalId);

    function MovementVoting(uint256 _endBlock){ //, uint _minTokenAmountToVote, string _urlVotingDetails) {
        endBlock = _endBlock;
		admin = msg.sender;
		//minTokenAmountToVote =_minTokenAmountToVote;
		//urlVotingDetails = _urlVotingDetails;
		checker = CheckTokenBalance(0x89eebb3ca5085ea737cc193b4a5d5b2b837ce548);
    }

	function changeEndBlock(uint256 _endBlock)
	onlyAdmin {
		endBlock = _endBlock;
	}

    function vote(int256 proposalId) {
        uint bala = checker.getTokenBalanceOf(msg.sender);
        //require(checker.getTokenBalanceOf(msg.sender) >= minTokenAmountToVote);
        require(msg.sender != address(0));
        require(proposalId > 0);
        require(endBlock == 0 || block.number <= endBlock);
        if (votes[msg.sender] == 0) {
            voters.push(msg.sender);
        }

        votes[msg.sender] = proposalId;

        onVote(msg.sender, proposalId);
    }

    function unVote() {

        require(msg.sender != address(0));
        require(votes[msg.sender] > 0);
        int256 proposalId = votes[msg.sender];
		votes[msg.sender] = -1;
        onUnVote(msg.sender, proposalId);
    }

    function votersCount()
    constant
    returns(uint256) {
        return voters.length;
    }
    
    /*function voteInfo()
    constant
    returns(string) {
        return urlVotingDetails;
    }*/

    function getVoters(uint256 offset, uint256 limit)
    constant
    returns(address[] _voters, int256[] _proposalIds) {

        if (offset < voters.length) {
            uint256 resultLength = limit;
            uint256 index = 0;

         
            if (voters.length - offset < limit) {
                resultLength = voters.length - offset;
            }

            _voters = new address[](resultLength);
            _proposalIds = new int256[](resultLength);

            for(uint256 i = offset; i < offset + resultLength; i++) {
                _voters[index] = voters[i];
                _proposalIds[index] = votes[voters[i]];
                index++;
            }

            return (_voters, _proposalIds);
        }
    }

	modifier onlyAdmin() {
		if (msg.sender != admin) revert();
		_;
	}
}
