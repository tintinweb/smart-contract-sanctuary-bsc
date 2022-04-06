// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract FavaLaunchpad{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;
    IERC20 rasingToken;
    IERC20 stakingToken;

    address[] whiteListed;

    uint256 public totalWeight;
    //Initial staking values for tires
    uint256 rank1 = 100 * (10 ** 18);
    uint256 rank2 = 200 * (10 ** 18);
    uint256 rank3 = 500 * (10 ** 18);
    uint256 rank4 = 1000 * (10 ** 18);
    uint256 rank5 = 99999999999999 * (10 ** 18);
    uint256 rank6 = 99999999999999 * (10 ** 18);
    
    uint256 weight1 = 5;
    uint256 weight2 = 15;
    uint256 weight3 = 25;
    uint256 weight4 = 35;
    uint256 weight5 = 0;
    uint256 weight6 = 0;

    struct Stake{
        uint256 amount;
        uint256 time;
    }
    mapping(address => Stake) stakes;

    struct Users{
        uint256 usedAllocation;
        bool claimed;
    }
    
    struct Projects{
        address tokenAdr;
        uint256 supply;
        uint256 soldAmount;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 distributionDate;
        uint256 whiteListAllocation;
        uint256 GAllocation;
        uint256 publicAllocation;
        uint256 price; //Per million tokens
        uint participants;
        bool withdrawn;
        mapping(address => Users) users;
    }

    mapping(address => Projects) public projects;

    constructor(address rasingTokenAdr, address stakingTokenAdr){
        rasingToken = IERC20(rasingTokenAdr);
        stakingToken = IERC20(stakingTokenAdr);
        owner = _msgSender();
    }

    function participate(address _ido,uint256 _amount) public returns(bool){
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(_amount > 0, "Amount should be greater than 0");
        require(project.supply.sub(project.soldAmount) >= _amount, "Not enough supply");
        require(block.timestamp > project.saleStart && block.timestamp < project.saleEnd, "Invalid IDO time");
        require(remainingAlloc(_ido, _msgSender()) >= project.users[_msgSender()].usedAllocation.add(_amount),
        "More allocation needed!");
        if(project.users[_msgSender()].usedAllocation == 0){
            project.participants++;
        }
        uint256 rasingTokenValue = (_amount.mul(project.price)) / 10 ** 6;
        rasingToken.safeTransferFrom(_msgSender(), address(this), rasingTokenValue);
        project.users[_msgSender()].usedAllocation = project.users[_msgSender()].usedAllocation + (_amount);
        project.soldAmount = project.soldAmount.add(_amount);

        return true;
    }

    function claimTokens(address _ido) public returns(bool){
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(block.timestamp > project.distributionDate);
        require(project.users[_msgSender()].claimed == false, "You already claimed your assets!");
        IERC20 token = IERC20(_ido);
        token.safeTransfer(_msgSender(), project.users[_msgSender()].usedAllocation);
        project.users[_msgSender()].claimed = true;
        
        return true;
    }

    function withdraw(address _ido,address payable _recipient) public onlyOwner {
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(project.withdrawn == false, "Already withdrawn!");
        require(block.timestamp > project.saleEnd);
        rasingToken.safeTransfer(_recipient, (project.soldAmount.mul(project.price)) / 10 ** 6);
        project.withdrawn = true;
    }

    function userDetails(address _project) public view returns(uint256, uint256, bool){
        Projects storage project = projects[_project];
        uint256 _usedAlloc = project.users[_msgSender()].usedAllocation;
        uint256 _remainingAllocation = remainingAlloc(_project, _msgSender());
        bool _claimed = project.users[_msgSender()].claimed;
        return (_usedAlloc, _remainingAllocation, _claimed);
    }

    function addIDO(address _tokenAdr,
                    uint256 _supply,
                    uint256 _saleStart,
                    uint256 _saleEnd,
                    uint256 _distributionDate,
                    uint256 _price,
                    uint256 _whiteListAllocation,
                    uint256 _GAllocation,
                    uint256 _publicAllocation
                    )public onlyOwner{
        require(projects[_tokenAdr].supply == 0, "Project already exists");
        IERC20 token = IERC20(_tokenAdr);
        token.safeTransferFrom(_msgSender(), address(this), _supply);

        Projects storage project = projects[_tokenAdr];

        project.tokenAdr = _tokenAdr;
        project.supply = _supply;
        project.saleStart = _saleStart;
        project.saleEnd = _saleEnd;
        project.distributionDate = _distributionDate;
        project.price = _price;
        project.whiteListAllocation = _whiteListAllocation;
        project.GAllocation = _GAllocation;
        project.publicAllocation = _publicAllocation;
    }

    function isWhiteListed(address _user) public view returns(bool){
        for(uint i = 0; i < whiteListed.length; i++){
            if(whiteListed[i] == _user){
                return true;
            }
        }
        return false;
    }

    function remainingAlloc(address _project ,address _user) internal view returns(uint256){
        Projects storage project = projects[_project];

        uint256 usedAlloc = project.users[_user].usedAllocation;
        uint256 _remaining = project.publicAllocation;
        if(isWhiteListed(_user)){
            _remaining += project.whiteListAllocation;
        }
        _remaining += stakeAlloc(_user, _project);
        _remaining -= usedAlloc;

        return _remaining;
    }

    function stakeAlloc(address _user, address _project) internal view returns(uint256){
        uint256 staked = stakes[_user].amount;

        if(staked >= rank6){
            return (projects[_project].GAllocation * weight6) / totalWeight;
        }else if(staked >= rank5){
            return (projects[_project].GAllocation * weight5) / totalWeight;
        }else if(staked >= rank4){
            return (projects[_project].GAllocation * weight4) / totalWeight;
        }else if(staked >= rank3){
            return (projects[_project].GAllocation * weight3) / totalWeight;
        }else if(staked >= rank2){
            return (projects[_project].GAllocation * weight2) / totalWeight;
        }else if(staked >= rank1){
            return (projects[_project].GAllocation * weight1) / totalWeight;
        }else{
            return 0;
        }
    }

    function stakeToken(uint256 _amount) public {
        require(_amount > 0, "Amount should be greater than 0");
        stakingToken.safeTransferFrom(_msgSender(), address(this), _amount);
        Stake storage stake = stakes[_msgSender()];
        stake.time = block.timestamp;

        if(stake.amount >= rank6){
            totalWeight -= weight6;
        }else if(stake.amount >= rank5){
            totalWeight -= weight5;
        }else if(stake.amount >= rank4){
            totalWeight -= weight4;
        }else if(stake.amount >= rank3){
            totalWeight -= weight3;
        }else if(stake.amount >= rank2){
            totalWeight -= weight2;
        }else if(stake.amount >= rank1){
            totalWeight -= weight1;
        }

        stake.amount = stake.amount.add(_amount);

        if(stake.amount >= rank6){
            totalWeight += weight6;
        }else if(stake.amount >= rank5){
            totalWeight += weight5;
        }else if(stake.amount >= rank4){
            totalWeight += weight4;
        }else if(stake.amount >= rank3){
            totalWeight += weight3;
        }else if(stake.amount >= rank2){
            totalWeight += weight2;
        }else if(stake.amount >= rank1){
            totalWeight += weight1;
        }
    }

    function unstakeToken() public {
        Stake storage stake = stakes[_msgSender()];
        require(stake.amount > 0, "No active stake!");
        if(stake.amount >= rank6){
            totalWeight -= weight6;
        }else if(stake.amount >= rank5){
            totalWeight -= weight5;
        }else if(stake.amount >= rank4){
            totalWeight -= weight4;
        }else if(stake.amount >= rank3){
            totalWeight -= weight3;
        }else if(stake.amount >= rank2){
            totalWeight -= weight2;
        }else if(stake.amount >= rank1){
            totalWeight -= weight1;
        }
        if((block.timestamp - stake.time) / 60 / 60 / 24 >= 14){
            uint256 pft = (getPercent(stake.amount, 15) * ((block.timestamp - stake.time) / 60 / 60 / 24)) / 365;
            stakingToken.safeTransfer(_msgSender(), stake.amount + pft);
            stake.amount = 0;
        }else{
            stakingToken.safeTransfer(_msgSender(), getPercent(stake.amount, 75));
            stake.amount = 0;
        }
    }

    //let owner to add whitelisted users
    function addWhite(address _user) public onlyOwner{
        if(!isWhiteListed(_user)){
            whiteListed.push(_user);
        }
    }

    //let owner to remove whitelisted users
    function remWhite(address _user) public onlyOwner{
        if(isWhiteListed(_user)){
            for(uint i = 0; i < whiteListed.length; i++){
                if(whiteListed[i] == _user){
                    delete whiteListed[i];
                }
            }
        }
    }
    
    //let owner to change raising token addresses
    function setRaiseToken(address _token) public onlyOwner{
        rasingToken = IERC20(_token);
    }
    //let owner to change staking token address
    function setStakeToken(address _token) public onlyOwner{
        stakingToken = IERC20(_token);
    }

    //let owner to change rank staking requirements
    function setRanks(uint256 _rank1, uint256 _rank2, uint256 _rank3, uint256 _rank4, uint256 _rank5, uint256 _rank6) public onlyOwner{
        rank1 = _rank1;
        rank2 = _rank2;
        rank3 = _rank3;
        rank4 = _rank4;
        rank5 = _rank5;
        rank6 = _rank6;
    }

    //let owner to change rank weights
    function setWeights(uint256 _weight1, uint256 _weight2, uint256 _weight3, uint256 _weight4, uint256 _weight5, uint256 _weight6) public onlyOwner{
        weight1 = _weight1;
        weight2 = _weight2;
        weight3 = _weight3;
        weight4 = _weight4;
        weight5 = _weight5;
        weight6 = _weight6;
    }

    //Transfer Ownership
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0) && newOwner != address(1), "Ownable: new owner is the zero address");
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(owner == _msgSender() || owner == address(0), "Ownable: caller is not the owner");
        _;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function getPercent(uint256 _val, uint _percent) internal pure  returns (uint256) {
        uint vald;
        vald = (_val * _percent) / 100 ;
        return vald;
    }

}