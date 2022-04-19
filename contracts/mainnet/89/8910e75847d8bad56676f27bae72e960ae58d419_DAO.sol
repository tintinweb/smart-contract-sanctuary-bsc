/**
 *Submitted for verification at BscScan.com on 2022-04-19
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
    using SafeMath for uint256;
    DAO DAOcontract;
    constructor() Auth(msg.sender) {
        DAOcontract = new DAO(msg.sender);
    }

    function rescueProxytok(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        uint256 tamt = BEP20(_tadd).balanceOf(address(this));
        BEP20(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function destructionProxy(uint256 amountPercentage, address destructor) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(destructor).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalanceProxy(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
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

    function setVotingActive(bool _bool) external authorized {
        DAOcontract.setVotingActive(_bool);
    }

    function startVoting(uint256 endTime, string memory _header, string memory _subheader) external authorized {
        DAOcontract.startVoting(endTime, _header, _subheader);
    }

    function startMultipleChoiceVoting(uint256 endTime, string memory _header, string memory _subheader, string memory _optionA, string memory _optionB, string memory _optionC, string memory _optionD) external authorized {
        DAOcontract.startMultipleChoiceVoting(endTime, _header, _subheader, _optionA, _optionB, _optionC, _optionD);
    }

    receive() external payable {}
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
    function setVotingActive(bool _bool) external;
    function startMultipleChoiceVoting(uint256 endTime, string memory _header, string memory _subheader, string memory _optionA, string memory _optionB, string memory _optionC, string memory _optionD) external;
    function startVoting(uint256 endTime, string memory _header, string memory _subheader) external;
}

contract DAO is IBEP20, IPROXY, Auth {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;
    uint256 VoteStart;
    uint256 VoteEnd;
    uint256 public VotesYes;
    uint256 public VotesNo;
    uint256 public VotesA;
    uint256 public VotesB;
    uint256 public VotesC;
    uint256 public VotesD;
    bool public votingActive = true;
    bool public whitelistVoting = false;
    bool public yesNoVoting = false;
    bool public multipleChoiceVoting = false;
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
        uint256 voteA;
        uint256 voteB;
        uint256 voteC;
        uint256 voteD;
        uint256 allVoteYes;
        uint256 allVoteNo;
        uint256 allVoteA;
        uint256 allVoteB;
        uint256 allVoteC;
        uint256 allVoteD;
        uint256 totalVotes;
        uint256 lastVoteCast; }

    struct pastVotingRecords {
        string header;
        string subheader;
        uint256 VoteStart;
        uint256 VoteEnd;
        uint256 VoteYes;
        uint256 VoteNo;
        uint256 VoteA;
        uint256 VoteB;
        uint256 VoteC;
        uint256 VoteD; }

    struct pastVoting {
        string header;
        string subheader;
        uint256 VoteStart;
        uint256 VoteEnd;
        uint256 VotesYes;
        uint256 VotesNo;
        string OptionA;
        uint256 VotesA;
        string OptionB;
        uint256 VotesB;
        string OptionC;
        uint256 VotesC;
        string OptionD;
        uint256 VotesD; }

    mapping (address => mapping (uint256 => pastVotingRecords)) private pastVotingRecord;
    mapping (address => votingRecord) private voter;
    mapping (uint256 => pastVoting) private pastVote;
    uint256 voteCount;

    string public optionA;
    string public optionB;
    string public optionC;
    string public optionD;
    string reset;
    string header;
    string subheader;

    constructor(address add) Auth(msg.sender) {
        authorize(add);
        VoteStart = block.timestamp;
        VoteEnd = block.timestamp;
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

    function viewvoteCount() public view returns (uint256) {
        return voteCount;
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

    function viewHasVoted(address _address) public view returns (bool) {
        bool hasVoted;
        if(pastVotingRecord[_address][voteCount].VoteYes > 0 || pastVotingRecord[_address][voteCount].VoteNo > 0 || pastVotingRecord[_address][voteCount].VoteA > 0 || pastVotingRecord[_address][voteCount].VoteB > 0 || pastVotingRecord[_address][voteCount].VoteC > 0 || pastVotingRecord[_address][voteCount].VoteD > 0){
        hasVoted = true;}
        else{hasVoted = false;}
        return hasVoted;
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

    function setVotingActive(bool _bool) external override authorized {
        votingActive = _bool;
    }

    function clearVotes() internal {
        VotesNo = 0; VotesYes = 0;
        VotesA = 0; VotesB = 0;
        VotesC = 0; VotesD = 0;
        optionA = reset; optionB = reset;
        optionC = reset; optionD = reset;
    }

    function archiveVotingNow() internal {
        pastVoting storage pvote = pastVote[voteCount];
        pvote.header = header;
        pvote.subheader = subheader;
        pvote.VoteStart = VoteStart;
        pvote.VoteEnd = VoteEnd;
        pvote.VotesYes = VotesYes;
        pvote.VotesNo = VotesNo;
        pvote.OptionA = optionA;
        pvote.VotesA = VotesA;
        pvote.OptionB = optionB;
        pvote.VotesB = VotesB;
        pvote.OptionC = optionC;
        pvote.VotesC = VotesC;
        pvote.OptionD = optionD;
        pvote.VotesD = VotesD;
    }

    function startMultipleChoiceVoting(uint256 endTime, string memory _header, string memory _subheader, string memory _optionA, string memory _optionB, string memory _optionC, string memory _optionD) external override authorized {
        require(block.timestamp >= VoteEnd);
        if(voteCount > 0){archiveVotingNow();}
        voteCount = voteCount.add(1);
        clearVotes();
        header = _header;
        subheader = _subheader;
        optionA = _optionA;
        optionB = _optionB;
        optionC = _optionC;
        optionD = _optionD;
        VoteStart = block.timestamp;
        VoteEnd = block.timestamp.add(endTime);
        votingActive = true;
        yesNoVoting = false;
        multipleChoiceVoting = true;
    }

    function startVoting(uint256 endTime, string memory _header, string memory _subheader) external override authorized {
        require(block.timestamp >= VoteEnd);
        if(voteCount > 0){archiveVotingNow();}
        voteCount = voteCount.add(1);
        clearVotes();
        header = _header;
        subheader = _subheader;
        VoteStart = block.timestamp;
        VoteEnd = block.timestamp.add(endTime);
        votingActive = true;
        yesNoVoting = true;
        multipleChoiceVoting = false;
    }

    function setVotingRecord(address _sender, uint256 _voteCount) internal {
        votingRecord storage thevoter = voter[_sender];
        pastVotingRecord[_sender][_voteCount].header = header;
        pastVotingRecord[_sender][_voteCount].subheader = subheader;
        pastVotingRecord[_sender][_voteCount].VoteStart = VoteStart;
        pastVotingRecord[_sender][_voteCount].VoteEnd = VoteEnd;
        pastVotingRecord[_sender][_voteCount].VoteYes = thevoter.voteYes;
        pastVotingRecord[_sender][_voteCount].VoteNo = thevoter.voteNo;
        pastVotingRecord[_sender][_voteCount].VoteA = thevoter.voteA;
        pastVotingRecord[_sender][_voteCount].VoteB = thevoter.voteB;
        pastVotingRecord[_sender][_voteCount].VoteC = thevoter.voteC;
        pastVotingRecord[_sender][_voteCount].VoteD = thevoter.voteD;
    }

    function _voteYes() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && yesNoVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 1; thevoter.voteNo = 0; thevoter.voteA = 0; thevoter.voteB = 0; thevoter.voteC = 0; thevoter.voteD = 0;
        thevoter.allVoteYes = thevoter.allVoteYes.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesYes = VotesYes.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function _voteNo() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && yesNoVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 0; thevoter.voteNo = 1; thevoter.voteA = 0; thevoter.voteB = 0; thevoter.voteC = 0; thevoter.voteD = 0;
        thevoter.allVoteNo = thevoter.allVoteNo.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesNo = VotesNo.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function _voteOptionA() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && multipleChoiceVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 0; thevoter.voteNo = 0; thevoter.voteA = 1; thevoter.voteB = 0; thevoter.voteC = 0; thevoter.voteD = 0;
        thevoter.allVoteA = thevoter.allVoteA.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesA = VotesA.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function _voteOptionB() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && multipleChoiceVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 0; thevoter.voteNo = 0; thevoter.voteA = 0; thevoter.voteB = 1; thevoter.voteC = 0; thevoter.voteD = 0;
        thevoter.allVoteB = thevoter.allVoteB.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesB = VotesB.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function _voteOptionC() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && multipleChoiceVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 0; thevoter.voteNo = 0; thevoter.voteA = 0; thevoter.voteB = 0; thevoter.voteC = 1; thevoter.voteD = 0;
        thevoter.allVoteC = thevoter.allVoteC.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesC = VotesC.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function _voteOptionD() external {
        votingRecord storage thevoter = voter[msg.sender];
        require(votingActive && multipleChoiceVoting);
        require(block.timestamp >= VoteStart && block.timestamp <= VoteEnd);
        if(whitelistVoting){require(isWhitelistVoter[msg.sender]);}
        if(tokenVoting){require(accessToken.balanceOf(msg.sender) >= minTokenHoldings);}
        if(nftVoting){require(accessNFT.balanceOf(msg.sender) >= minNFTHoldings);}
        if(thevoter.lastVoteCast <= VoteStart){voted[msg.sender] = false;}
        require(!voted[msg.sender]);
        thevoter.voteYes = 0; thevoter.voteNo = 0; thevoter.voteA = 0; thevoter.voteB = 0; thevoter.voteC = 0; thevoter.voteD = 1;
        thevoter.allVoteD = thevoter.allVoteD.add(1);
        thevoter.totalVotes = thevoter.totalVotes.add(1);
        thevoter.lastVoteCast = block.timestamp;
        VotesD = VotesD.add(1);
        voted[msg.sender] = true;
        setVotingRecord(msg.sender, voteCount);
    }

    function viewVoterStats(address _address) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        address wallet = _address;
        votingRecord storage thevoter = voter[wallet];
        return(
            thevoter.voteYes,
            thevoter.voteNo,
            thevoter.voteA,
            thevoter.voteB,
            thevoter.voteC,
            thevoter.voteD,
            thevoter.allVoteYes,
            thevoter.allVoteNo,
            thevoter.allVoteA,
            thevoter.allVoteB,
            thevoter.allVoteC,
            thevoter.allVoteD,
            thevoter.totalVotes,
            thevoter.lastVoteCast
            );
    }

    function viewCurrentVoterStats(address _address) public view returns (string memory, string memory, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        address wallet = _address;
        return(
            pastVotingRecord[wallet][voteCount].header,
            pastVotingRecord[wallet][voteCount].subheader,
            pastVotingRecord[wallet][voteCount].VoteStart,
            pastVotingRecord[wallet][voteCount].VoteEnd,
            pastVotingRecord[wallet][voteCount].VoteYes,
            pastVotingRecord[wallet][voteCount].VoteNo,
            pastVotingRecord[wallet][voteCount].VoteA,
            pastVotingRecord[wallet][voteCount].VoteB,
            pastVotingRecord[wallet][voteCount].VoteC,
            pastVotingRecord[wallet][voteCount].VoteD
            );
    }

    function viewPastVoterStats(address _address, uint256 _voteCount) public view returns (string memory, string memory, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        address wallet = _address;
        uint256 voteNumber = _voteCount;
        return(
            pastVotingRecord[wallet][voteNumber].header,
            pastVotingRecord[wallet][voteNumber].subheader,
            pastVotingRecord[wallet][voteNumber].VoteStart,
            pastVotingRecord[wallet][voteNumber].VoteEnd,
            pastVotingRecord[wallet][voteNumber].VoteYes,
            pastVotingRecord[wallet][voteNumber].VoteNo,
            pastVotingRecord[wallet][voteNumber].VoteA,
            pastVotingRecord[wallet][voteNumber].VoteB,
            pastVotingRecord[wallet][voteNumber].VoteC,
            pastVotingRecord[wallet][voteNumber].VoteD
            );
    }

    function viewCurrentVoteStats() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
            return(
                VoteStart,
                VoteEnd,
                VotesYes,
                VotesNo,
                VotesA,
                VotesB,
                VotesC,
                VotesD
            );
    }

    function viewPastVoteInfo(uint256 voteNumber) public view returns (string memory, string memory, uint256, uint256) {
        uint256 votenumber = voteNumber;
        pastVoting storage pvote = pastVote[votenumber];
        return(
            pvote.header,
            pvote.subheader,
            pvote.VoteStart,
            pvote.VoteEnd
            );
    }

        function viewPastVoteStats(uint256 voteNumber) public view returns (string memory, string memory, uint256, uint256, string memory, uint256, string memory, uint256, string memory, uint256, string memory, uint256) {
        uint256 votenumber = voteNumber;
        pastVoting storage pvote = pastVote[votenumber];
        return(
            pvote.header,
            pvote.subheader,
            pvote.VotesYes,
            pvote.VotesNo,
            pvote.OptionA,
            pvote.VotesA,
            pvote.OptionB,
            pvote.VotesB,
            pvote.OptionC,
            pvote.VotesC,
            pvote.OptionD,
            pvote.VotesD
            );
    }
}