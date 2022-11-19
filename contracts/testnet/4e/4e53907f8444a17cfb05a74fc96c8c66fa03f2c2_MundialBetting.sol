/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: contracts/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: contracts/Auth.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
// File: contracts/MundialBetting1.sol



pragma solidity ^0.8.17;



contract MundialBetting is Auth {

    IERC20 public token;

    struct Match {
        uint256 index;      
        uint256 start;  
        uint256 end;  
        
        string team1;
        string team2;
        string team1Logo;
        string team2Logo;
        uint256 group; //1,2,3,4,5,6,7,8

        uint256 win1; //team1
        uint256 win0; //draw
        uint256 win2; //team2

        bool finished;
        uint256 score1; //Goals by team1
        uint256 score2; //Goals by team2
    }

    struct Odd {
        uint256 time;  
        uint256 bet;
        uint256 amount;
        uint256 claim;
        uint256 claimTime;
    }
    uint256 private _denominator = 10000;
    
    Match[64] public Matchs; //64
    mapping (address => mapping (uint => Odd)) public Odds; //user -> match -> Betting odd

    struct Champ {
        string team;
        string teamLogo;
        uint256 win;
        address[] bettors;
    }
    struct OddChamp {
        uint256 team;
        uint256 time;  
        uint256 amount;
        uint256 claim;
        uint256 claimTime;
        uint256 rate;
    }
    Champ[32] public Champions;
    mapping (address => OddChamp) public Codds; //user -> Champion odd
    mapping (uint256 => Champ) public ChampionDetails; //Details of champion teams
    bool public Finished = false; 
    uint public ChampionTeam; 

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }
    
    event Predicted(uint256 _match, uint256 _amount, uint _type);
    event MatchFinished(uint256 _matchid, uint256 score1, uint256 score2);

    constructor(IERC20 _token) Auth(msg.sender){
        token = _token;
    }

    //match = index - 1
    function setMatch(uint256 _match, uint256 _start, string calldata _team1, string calldata _team2, string calldata _team1Logo, string calldata _team2Logo, uint256 _group) external onlyOwner{
        Matchs[_match].start = _start;
        Matchs[_match].team1 = _team1;
        Matchs[_match].team2 = _team2;
        Matchs[_match].team1Logo = _team1Logo;
        Matchs[_match].team2Logo = _team2Logo;
        Matchs[_match].group = _group;
    }
    function setOdds(uint256 _match, uint256 _win1, uint256 _win0, uint256 _win2) external onlyOwner{
        Matchs[_match].win0 = _win0;
        Matchs[_match].win1 = _win1;
        Matchs[_match].win2 = _win2;
    }

    function setResult(uint256 _index, bool _finished, uint256 _score1, uint256 _score2) external onlyOwner{
        Matchs[_index -1].finished = _finished;
        Matchs[_index -1].score1 = _score1;
        Matchs[_index -1].score2 = _score2;
        Matchs[_index -1].end = block.timestamp;
        emit MatchFinished(_index -1,  _score1, _score2);
    }

    function setChampion(uint _team, bool _finished) external onlyOwner{
        Finished = _finished;
        ChampionTeam = _team;
    }

    function setMultiple(uint256 _mul) external onlyOwner{
        for (uint i = 0; i < Matchs.length; i++) {
            Matchs[i].win0 = (Matchs[i].win0 * _mul) / _denominator;
            Matchs[i].win1 = (Matchs[i].win1 * _mul) / _denominator;
            Matchs[i].win2 = (Matchs[i].win2 * _mul) / _denominator;
        }
    }

    function setChampionRate(uint256[] calldata _win) external onlyOwner{
        for (uint i = 0; i < _win.length; i++) {
            Champions[i].win = _win[i];
        }
    }

    function setMatches(uint256[] calldata _match, uint256[] calldata _start, string[] calldata _team1, string[] calldata _team2, string[] calldata _team1Logo, string[] calldata _team2Logo) external onlyOwner{
        for (uint i = 0; i < _match.length; i++) {
            Matchs[_match[i]].index = i + 1;
            Matchs[_match[i]].start = _start[i];
            Matchs[_match[i]].team1 = _team1[i];
            Matchs[_match[i]].team2 = _team2[i];
            Matchs[_match[i]].team1Logo = _team1Logo[i];
            Matchs[_match[i]].team2Logo = _team2Logo[i];
        }
    }
    function setOdds(uint256[] calldata _match, uint256[] calldata _win1, uint256[] calldata _win0, uint256[] calldata _win2, uint256[] calldata _group) external onlyOwner{
        for (uint i = 0; i < _match.length; i++) {
            Matchs[_match[i]].win0 = _win0[i];
            Matchs[_match[i]].win1 = _win1[i];
            Matchs[_match[i]].win2 = _win2[i];
            Matchs[_match[i]].group = _group[i];
        }
    }
    function setChams(string[] calldata _team, string[] calldata _teamLogo, uint256[] calldata _win) external onlyOwner{
        for (uint i = 0; i < _team.length; i++) {
            Champions[i].team = _team[i];
            Champions[i].teamLogo = _teamLogo[i];
            Champions[i].win = _win[i];
        }
    }

    //user: _matchid: 1 -> 64, outcome 0-draw, 1-team1, 2-team2
    function placeBet(uint256 _index, uint256 _outcome, uint256 _amount) external callerIsUser {
        require(_amount > 0, "Amount is 0");
        require(_outcome < 3, "Type is 0 1 2");
        require(_index < 65, "Out of matchs");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        
        Match memory mtch = Matchs[_index - 1];
        require(mtch.start > block.timestamp, "Match started");
        token.transferFrom(msg.sender, address(this), _amount);
        Odd memory od = Odd(block.timestamp, _outcome, _amount, 0, 0);
        Odds[msg.sender][_index - 1] = od;
    }
    function cancel(uint256 _index) external callerIsUser {
        require(_index < 65, "Only 64 matches to choose from");
        require(Matchs[_index - 1].start > block.timestamp + 3600, "locked 1h before start");

        uint256 apv = Odds[msg.sender][_index - 1].amount;
        require(apv > 0, "This match has not been approved");
        require(!Matchs[_index - 1].finished, "this match has ended");
        token.transfer(msg.sender, apv);
        Odd memory od = Odd(0, 0, 0, 0, 0);
        Odds[msg.sender][_index - 1] = od;
    }

    function predictChampion(uint _team, uint256 _amount) external callerIsUser {
        require(_amount > 0, "Amount is 0");
        require(_team < 32, "Only 32 teams to choose from.");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        require(block.timestamp < Matchs[0].start, "Group Stage has ended! You can't take part now.");

        token.transferFrom(msg.sender, address(this), _amount);
        OddChamp memory od = OddChamp(_team, block.timestamp, _amount, 0, 0, Champions[_team].win);
        Codds[msg.sender] = od;
        Champions[_team].bettors.push(msg.sender);
    }

    function cancelchampion() external callerIsUser {
        uint256 apv = Codds[msg.sender].amount;
        require(apv > 0, "Not approved");
        require(!Finished, "wc finished");
        require(block.timestamp < Matchs[47].start, "Group Stage has ended! You can't cancel now.");
        token.transfer(msg.sender, apv);
        OddChamp memory od = OddChamp(0, 0, 0, 0, 0, 0);
        Codds[msg.sender] = od;
    }

    function _calculateOdds(uint256 _matchid, address user) internal view  returns (bool finished, bool won, uint256 wonAmount) {
        Match memory m = Matchs[_matchid];
        if (!m.finished) {
            return (false, false, 0);
        } else {
            Odd memory od = Odds[user][_matchid];
            if (m.score1 > m.score2 && od.bet == 1) {
                return (true, true, (m.win1 * od.amount) / _denominator);
            }
            if (m.score1 == m.score2 && od.bet == 0) {
                return (true, true, (m.win0 * od.amount) / _denominator);
            }
            if (m.score1 < m.score2 && od.bet == 2) {
                return (true, true, (m.win2 * od.amount) / _denominator);
            }
        }
        return (true, false, 0);
    }

    function userinfo(address user) public view returns (uint256 stakeAmount, uint256 claimAmount, uint256 applyOdds, uint256 winOdds, uint256 lostOdds, uint256 claimed) {
        stakeAmount = 0;
        claimed = 0;
        for (uint i = 0; i < Matchs.length; i++) {
            if (Odds[user][i].amount > 0) {
                stakeAmount += Odds[user][i].amount;
                claimed += Odds[user][i].claim;
                applyOdds ++;
            }
            (bool f, bool w,uint256 c) = _calculateOdds(i, user);
            claimAmount += c;
            winOdds += f ? w ? 1 : 0 : 0;
            lostOdds += f ? w ? 0 : 1 : 0;
        }    
        return (stakeAmount, claimAmount, applyOdds, winOdds, lostOdds, claimed);
    }
    
    function claim() external callerIsUser {
        uint256 _amount = 0;
        for (uint i = 0; i < Matchs.length; i++) {
            ( , ,uint256 c) = _calculateOdds(i, msg.sender);
            if (c > 0 && Odds[msg.sender][i].claim == 0) {
                _amount += c;
                Odds[msg.sender][i].claim += c;
                Odds[msg.sender][i].claimTime = block.timestamp;
            }
        }  
        require(_amount > 0, "Reward is 0");
        token.transfer(address(msg.sender), _amount);
    }

    function claimChampion() external callerIsUser {
        require(Finished, "WC runing");
        OddChamp memory od = Codds[msg.sender];
        uint256 _amount = 0;
        if (od.team == ChampionTeam && od.claim == 0) {
            _amount = od.amount * (Champions[ChampionTeam].win) / _denominator;
        }
        require(_amount > 0, "Reward is 0");
        od.claim = _amount;
        od.claimTime = block.timestamp;
        Codds[msg.sender] = od;
        token.transfer(address(msg.sender), _amount);
    }

    //token
    function setToken(address _token) external onlyOwner{
        require(_token != address(0));
        token = IERC20(_token);
    }

    function withdrawToken(address _to, uint256 _amount) external onlyOwner{
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        require(_to != address(0), "Destination is 0");
        token.transfer(_to, _amount);
    }

    function emergencyWithdraw() public {
        uint256 _amount = 0;
        for (uint i = 0; i < Matchs.length; i++) {
            if (Odds[msg.sender][i].amount > 0 && Odds[msg.sender][i].claim == 0) {
                _amount += Odds[msg.sender][i].amount;
                Odds[msg.sender][i].amount = 0;
                Odds[msg.sender][i].time = 0;
            }
        }    
        require(_amount > 0, "no match found");
        token.transfer(address(msg.sender), _amount);
    }

    function withdrawBNB(address _to, uint _amount) external onlyOwner{
        require(address(this).balance >= _amount, "Not enough balance");
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "withdraw failed");
    }

    receive() external payable {}
}