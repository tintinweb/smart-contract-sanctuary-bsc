/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

/**

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface BEP20 {
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

contract PROXYDEPLOYER is Auth {
    DAO DAOcontract;
    constructor() Auth(msg.sender) {
        DAOcontract = new DAO(msg.sender);
    }

    function rescuetok(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        DAOcontract.rescuetok(_tadd, _rec, _amt, _amtd);
    }

    function rescuecro(uint256 amountPercentage) external authorized {
        DAOcontract.clearStuckBalance(amountPercentage);
    }

    function destruction(uint256 amountPercentage, address destructor) external authorized {
        DAOcontract.destruction(amountPercentage, destructor);
    }

    function setWLVotingActive(bool _bool) external authorized {
        DAOcontract.setWLVotingActive(_bool);
    }

    function setTokenAccess(address _token) external authorized {
        DAOcontract.setTokenAccess(_token);
    }

    function setTokenVotingActive(bool _bool) external authorized {
        DAOcontract.setTokenVotingActive(_bool);
    }

    function setMinTokenAccess(uint256 _amount) external authorized {
        DAOcontract.setMinTokenAccess(_amount);
    }

    function setNFTAccess(address _nft) external authorized {
        DAOcontract.setNFTAccess(_nft);
    }

    function setNFTVotingActive(bool _bool) external authorized {
        DAOcontract.setNFTVotingActive(_bool);
    }

    function setMinNFTAccess(uint256 _amount) external authorized {
        DAOcontract.setMinNFTAccess(_amount);
    }

    function setHeader(string memory _header) external authorized {
        DAOcontract.setHeader(_header);
    }

    function setsubHeader(string memory _header) external authorized {
        DAOcontract.setsubHeader(_header);
    }

    function setHeaders(string memory _header, string memory _subheader) external authorized {
        DAOcontract.setHeaders(_header, _subheader);
    }

    function setIsWhitelistVoter(address _address, bool _bool) external authorized {
        DAOcontract.setIsWhitelistVoter(_address, _bool);
    }

    function setIsWhitelistVoters(bool _bool, address[] calldata addresses) external authorized {
        DAOcontract.setIsWhitelistVoters(_bool, addresses);
    }

    function resetVoting() external authorized {
        DAOcontract.resetVoting();
    }

    function setVotingActive(bool _bool) external authorized {
        DAOcontract.setVotingActive(_bool);
    }

    function stopVoting() external authorized {
        DAOcontract.stopVoting();
    }

    function startVoting(uint256 time) external authorized {
        DAOcontract.startVoting(time);
    }
}

interface IPROXY {
    function rescuetok(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external;
    function clearStuckBalance(uint256 amountPercentage) external;
    function destruction(uint256 amountPercentage, address destructor) external;
    function setWLVotingActive(bool _bool) external;
    function setTokenAccess(address _token) external;
    function setTokenVotingActive(bool _bool) external;
    function setMinTokenAccess(uint256 _amount) external;
    function setNFTAccess(address _nft) external;
    function setNFTVotingActive(bool _bool) external;
    function setMinNFTAccess(uint256 _amount) external;
    function setHeader(string memory _header) external;
    function setsubHeader(string memory _header) external;
    function setHeaders(string memory _header, string memory _subheader) external;
    function setIsWhitelistVoter(address _address, bool _bool) external;
    function setIsWhitelistVoters(bool _bool, address[] calldata addresses) external;
    function resetVoting() external;
    function setVotingActive(bool _bool) external;
    function stopVoting() external;
    function startVoting(uint256 time) external;
}

contract DAO is IBEP20, IPROXY, Auth {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;
    uint256 VoteStart;
    uint256 VoteEnd;
    uint256 VotesYes;
    uint256 VotesNo;
    bool public VotingActive = true;
    string header = 'Voting for the President';
    string subheader = 'One Vote Per Voter Address';
    bool public whitelistVoting = false;
    mapping (address => bool) isWhitelistVoter;
    mapping (address => bool) voted;
    IBEP20 public accessToken;
    bool public tokenVoting = false;
    IBEP20 public accessNFT;
    bool public nftVoting = false;
    uint256 minTokenHoldings = 100000;
    uint256 minNFTHoldings = 1;

    struct votingRecord {
        uint256 voteYes;
        uint256 voteNo;
        uint256 allVoteYes;
        uint256 allVoteNo;
        uint256 totalVotes;
        uint256 lastVoteCast;
    }

    mapping (address => votingRecord) private voter;

    constructor(address add) Auth(msg.sender) {
        authorize(add);
    }

    receive() external payable {}

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferFrom(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function rescuetok(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external override authorized {
        uint256 tamt = BEP20(_tadd).balanceOf(address(this));
        BEP20(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function destruction(uint256 amountPercentage, address destructor) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(destructor).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalance(uint256 amountPercentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function setWLVotingActive(bool _bool) external override authorized {
        whitelistVoting = _bool;
    }

    function setTokenAccess(address _token) external override authorized {
        accessToken = IBEP20(_token);
    }

    function setTokenVotingActive(bool _bool) external override authorized {
        tokenVoting = _bool;
    }

    function setMinTokenAccess(uint256 _amount) external override authorized {
        minTokenHoldings = _amount;
    }

    function setNFTAccess(address _nft) external override authorized {
        accessNFT = IBEP20(_nft);
    }

    function setNFTVotingActive(bool _bool) external override authorized {
        nftVoting = _bool;
    }

    function setMinNFTAccess(uint256 _amount) external override authorized {
        minNFTHoldings = _amount;
    }

    function viewMinTokenAccess() public view returns (uint256) {
        return minTokenHoldings;
    }

    function viewMinNFTAccess() public view returns (uint256) {
        return minNFTHoldings;
    }

    function viewVoteStart() public view returns (uint256) {
        return VoteStart;
    }

    function viewVoteEnd() public view returns (uint256) {
        return VoteEnd;
    }

    function viewVotesYes() public view returns (uint256) {
        return VotesYes;
    }

    function viewVotesNo() public view returns (uint256) {
        return VotesNo;
    }

    function viewIsWhitelistVoter(address _address) public view returns (bool) {
        return isWhitelistVoter[_address];
    }

    function _viewHeader() public view returns (string memory) {
        return header;
    }

    function setHeader(string memory _header) external override authorized {
        header = _header;
    }

    function _viewsubHeader() public view returns (string memory) {
        return subheader;
    }

    function viewVoterStats(address _address) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        votingRecord storage thevoter = voter[_address];
        return(
            thevoter.voteYes,
            thevoter.voteNo,
            thevoter.allVoteYes,
            thevoter.allVoteNo,
            thevoter.totalVotes,
            thevoter.lastVoteCast
            );
    }

    function setsubHeader(string memory _header) external override authorized {
        subheader = _header;
    }

    function setHeaders(string memory _header, string memory _subheader) external override authorized {
        header = _header;
        subheader = _subheader;
    }

    function setIsWhitelistVoter(address _address, bool _bool) external override authorized {
        isWhitelistVoter[_address] = _bool;
    }

    function setIsWhitelistVoters(bool _bool, address[] calldata addresses) external override authorized {
        for(uint i=0; i < addresses.length; i++){
        isWhitelistVoter[addresses[i]] = _bool;}
    }

    function resetVoting() external override authorized {
        VoteStart = block.timestamp;
        VoteEnd = block.timestamp;
        VotingActive = false;
        VotesNo = 0;
        VotesYes = 0;
    }

    function setVotingActive(bool _bool) external override authorized {
        VotingActive = _bool;
    }

    function stopVoting() external override authorized {
        VotingActive = false;
    }

    function startVoting(uint256 time) external override authorized {
        VoteStart = block.timestamp;
        VoteEnd = block.timestamp.add(time);
        VotingActive = true;
        VotesNo = 0;
        VotesYes = 0;
    }

    function _voteYes() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(VotingActive);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes == 1;
        thevoter.voteNo == 0;
        thevoter.allVoteYes == thevoter.allVoteYes.add(1);
        thevoter.totalVotes == thevoter.totalVotes.add(1);
        thevoter.lastVoteCast == block.timestamp;
        VotesYes = VotesYes.add(1);
        voted[msg.sender] = true;
    }

    function _voteNo() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(VotingActive);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes == 0;
        thevoter.voteNo == 1;
        thevoter.allVoteNo == thevoter.allVoteNo.add(1);
        thevoter.totalVotes == thevoter.totalVotes.add(1);
        thevoter.lastVoteCast == block.timestamp;
        VotesNo = VotesNo.add(1);
        voted[msg.sender] = true;
    }
}