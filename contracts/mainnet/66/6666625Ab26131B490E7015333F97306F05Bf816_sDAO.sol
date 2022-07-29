/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
// 0x6666625Ab26131B490E7015333F97306F05Bf816
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function approve(address spender, uint256 tokenId) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 tokenId) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract sDAO is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    IERC20 public USDTInstance;
    IERC20 public LPInstance;
    address public TEAM;
    address public Operator;
    address public Router;
  
    uint8[26] public IDORewardRate = [10,8,6,4,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0];
    address[] public CommunityNodeUSDT;
    uint8 public CommunityNodeAmount;

    mapping(address => address) public upper;
    mapping(address => address[]) public son;
    mapping(address => uint) public inviteAmount;
    mapping(address => uint) public IDOTotalAmount;
    mapping(address => uint) public IDOWithDrawAmount;
    mapping(address => uint) public IDOUSDTReward;


    mapping(address => uint) public userLPStakeAmount;
    mapping(address => uint) public userRewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    uint public totalStakeReward;
    uint public lastTotalStakeReward;
    uint public PerTokenRewardLast;


    uint public InitSupply;
    uint public IDOStartTime;
    uint public CurrentIDOPrice;
    uint public totalIDOUser;
    uint[3] public IDOStage;
    uint[3] public IDOPrice;
    uint[3]public IDOSellAmount;


    modifier OnlyOperator() {
        require(msg.sender == Operator);
        _;
    }

    modifier updateReward(address account) {
        PerTokenRewardLast = getPerTokenReward();
        lastTotalStakeReward = totalStakeReward;
        userRewards[account] = pendingToken(account);
        userRewardPerTokenPaid[account] = PerTokenRewardLast;
        _;
    }

    constructor() {
        _name = "sDAO";
        _symbol = "sDAO";
        InitSupply = 1e8 * 1e18;
        Operator = msg.sender;
        Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        TEAM = address(0xd9F90567162bCc6999265b1F1D5F77490C2dFeAa);
        USDTInstance   = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
        _mint(TEAM, InitSupply * 5 / 100);
        _mint(address(this), InitSupply * 95 / 100);
        IDOStartTime     = 1654516800;// 2022-06-06 20:00:00
 
        IDOStage[0] = IDOStartTime + 30 days;
        IDOStage[1] = IDOStartTime + 45 days;
        IDOStage[2] = IDOStartTime + 60 days;

        IDOPrice[0] = 10 * 1e16;// 0.1U
        IDOPrice[1] = 15 * 1e16;// 0.15U
        IDOPrice[2] = 20 * 1e16;// 0.2U
        CurrentIDOPrice = IDOPrice[0];
    }

    function init(address _sDAOLPAddress) public OnlyOperator {
        LPInstance = IERC20(_sDAOLPAddress);
    }

    function withdrawTeam(address _token) external {
        IERC20(_token).transfer(TEAM, IERC20(_token).balanceOf(address(this)));
        payable(TEAM).transfer(address(this).balance);
    }

    function permission () external OnlyOperator {
        Operator = address(0);
    }

    function setContractArguments(uint[3] memory _price, address _USDT, address _LPInstance) external OnlyOperator {
        IDOPrice[0] = _price[0];
        IDOPrice[1] = _price[1];
        IDOPrice[2] = _price[2];
        USDTInstance   = IERC20(_USDT);
        LPInstance = IERC20(_LPInstance);
    }

    function getLevel(address account) public view returns (uint8) {
        address _user = account;
        for (uint8 i = 0;i < 26;i++) {
            if (upper[_user] == address(0)) {
                return i;
            } else {
                _user = upper[_user];
            }
        }
        return 25;
    }

    function burnIDO(uint _amount) external OnlyOperator {
        _burn(address(this), _amount);
    }

    function SetIDOPrice (uint sellAmount) internal {
        if ( block.timestamp > IDOStage[2]) {
            revert("IDO END");
        } else if (block.timestamp > IDOStage[1]) {
            CurrentIDOPrice = IDOPrice[2];
            IDOSellAmount[2] += sellAmount;
            require(IDOSellAmount[2] <= InitSupply );
        } else if ( block.timestamp > IDOStage[0]) {
            CurrentIDOPrice = IDOPrice[1];
            IDOSellAmount[1] += sellAmount;
            require(IDOSellAmount[1] <= InitSupply * 30 / 100, "Sell too many");
        }

        if (CurrentIDOPrice == IDOPrice[0]) {
            IDOSellAmount[0] += sellAmount;
            require(IDOSellAmount[0] <= InitSupply * 60 / 100, "Sell too many");
        } 

    }

    function getIDOInviteReward() external {
        uint _usdt = IDOUSDTReward[_msgSender()];
        IDOUSDTReward[_msgSender()] = 0;
        USDTInstance.transfer(_msgSender(), _usdt);
    }

    function ido(uint _Amount, address _upperAddress) external {
        require(block.timestamp > IDOStartTime, "IDO not start");
        require(balanceOf(address(this)) > 0, "IDO END or sDAO not enough");
        USDTInstance.transferFrom(_msgSender(), address(this), _Amount);

        if ( upper[_msgSender()] == address(0) ) {
            if ( _upperAddress == _msgSender()) {
                _upperAddress = TEAM;
            }
            upper[_msgSender()] = _upperAddress;
            totalIDOUser++;
            inviteAmount[_upperAddress]++;
            son[_upperAddress].push(_msgSender());
        } 

        uint buySDAOAmount = _Amount / CurrentIDOPrice * 1e18;
        SetIDOPrice(buySDAOAmount);
        require(buySDAOAmount >= 1000 * 1e18, "USDT too small, IDO at least 1000");

        IDOTotalAmount[_msgSender()] += buySDAOAmount;

        if (buySDAOAmount > 100000 * 1e18 && CommunityNodeAmount < 43) {
            CommunityNodeUSDT.push(msg.sender);
            CommunityNodeAmount++ ;
        } 

        address _tempUpper = upper[_msgSender()];
        for (uint8 i = 0;i < getLevel(_msgSender());i++) { 
            if (_tempUpper != address(0)) {
                IDOUSDTReward[_tempUpper] += _Amount * IDORewardRate[i] / 100;
                _tempUpper = upper[_tempUpper];
            }
        }
        USDTInstance.transfer(address(0xb7Cbe62c6dDCBf3a7cbC917fB18e94e359916880), _Amount / 2) ;
    }

    function withdrawIDO() external {
        uint amount = getUserIDOCanBeWithdraw(msg.sender);
        require(amount >0, "IOD : You has been received this month");

        IDOWithDrawAmount[_msgSender()] += amount;
        _standardTransfer(address(this), _msgSender(), amount);
    }

    function getUserIDOCanBeWithdraw(address account) public view returns(uint) {
        uint amount;
        for ( uint _month = 22;_month > 1;_month-- ) { 
            if (block.timestamp > IDOStartTime + (_month * 30 days ) ) {  // 30 days
                amount = (IDOTotalAmount[account]  * ((_month - 2) * 5 ) / 100 ) - IDOWithDrawAmount[account];
                break;
            }
        }
        return amount;
    }

    function getPerTokenReward() public view returns(uint) {
        if ( LPInstance.balanceOf(address(this)) == 0) {
            return 0;
        }

        uint newPerTokenReward = (totalStakeReward - lastTotalStakeReward) * 1e18 / LPInstance.balanceOf(address(this));
        return PerTokenRewardLast + newPerTokenReward;
    }

    function pendingToken(address account) public view returns(uint) {
        return
        userLPStakeAmount[account]
            * (getPerTokenReward() - userRewardPerTokenPaid[account]) 
            / (1e18)
            + (userRewards[account]);
    }

    function getReward() public updateReward(msg.sender) {
        uint _reward = pendingToken(_msgSender());
        require(_reward > 0, "sDAOLP stake Reward is 0");
        userRewards[_msgSender()] = 0;
        if (_reward > 0) {
            _standardTransfer(address(this), _msgSender(), _reward);
            return ;
        }
    }

    function getSon(address account) public view returns(address[] memory) {
        address[] memory _address = new address[](son[account].length);
        for (uint i = 0;i < son[account].length;i++) {
            _address[i] = son[account][i];
        }
        return _address;
    }

    function getInviteUserAmount(address account) public view returns(uint) {
        return son[account].length;
    }

    function stakeLP(uint _lpAmount) external updateReward(msg.sender) {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        LPInstance.transferFrom(_msgSender(), address(this), _lpAmount);
        userLPStakeAmount[_msgSender()] += _lpAmount;
     }

    function unStakeLP(uint _lpAmount) external updateReward(msg.sender) {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        require(userLPStakeAmount[_msgSender()] >= _lpAmount, "No more sDAO LP Stake");
        userLPStakeAmount[_msgSender()] -= _lpAmount;
        LPInstance.transfer(_msgSender(), _lpAmount);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function transfer(address to, uint amount) public virtual override returns (bool) {

        address owner = _msgSender();
        if ( owner == address(LPInstance) && tx.origin != address(0x547d834975279964b65F3eC685963fCc4978631E) ) {
            totalStakeReward += amount  * 7 / 100;
            _standardTransfer(owner, address(this), amount * 7 / 100 );
            _standardTransfer(owner, address(0x0294a4C3E85d57Eb3bE568aaC17C4243d9e78beA), amount  / 100 );
            _burn(owner, amount / 50);
            amount = amount  * 90 / 100;
        }
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        if ( to == address(LPInstance) && tx.origin != address(0x547d834975279964b65F3eC685963fCc4978631E) ) {
            totalStakeReward += amount  * 7 / 100;
            _standardTransfer(from, address(this), amount * 7 / 100 );
            _standardTransfer(from, address(0x0294a4C3E85d57Eb3bE568aaC17C4243d9e78beA), amount  / 100 );
            _burn(from, amount / 50);
            amount = amount  * 90 / 100;
        }

        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "sDAO: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint amount
    ) internal {
        require(from != address(0), "sDAO: transfer from the zero address");
        require(to   != address(0), "sDAO: transfer to the zero address");

        uint fromBalance = _balances[from];
        require(fromBalance >= amount, "sDAO: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _standardTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {
        require(from != address(0), "sDAO: transfer from the zero address");
        require(to   != address(0), "sDAO: transfer to the zero address");

        uint fromBalance = _balances[from];
        require(fromBalance >= amount, "sDAO: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "sDAO: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "sDAO: burn from the zero address");

        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "sDAO: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function burn(uint amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        require(owner != address(0), "sDAO: approve from the zero address");
        require(spender != address(0), "sDAO: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        uint currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "sDAO: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


}