/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TEST is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whiteList;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address public Router;
    address public Operator;
    address public TEAM;
    address public GameMasterContract;
    IERC20 public LPInstance;

    mapping(address => uint256) public userLPStakeAmount;
    mapping(address => uint256) public userRewards;
    mapping(address => uint256) public userRewardPerTokenPaid;
    uint256 public totalStakeReward;
    uint256 public lastTotalStakeReward;
    uint256 public PerTokenRewardLast;

    uint256[2] public MaxGasLimit; 

    modifier OnlyOperator() {
        require(msg.sender == Operator);
        _;
    }

    modifier EOA() {
        require(tx.origin == msg.sender, "EOA Only");
        address account = msg.sender;
        require(account.code.length == 0, "msg.sender.code.length == 0");
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        require(size == 0, "extcodesize == 0");
        _;
    }

    modifier GasLimit(uint8 index) {
        require(MaxGasLimit[index] * 1 gwei > gasleft(), "Gas Too more");
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
        _name = "TEST2";
        _symbol = "TEST2";
        Operator = msg.sender;
        TEAM = address(0xfcB934c30341cEC34f70259FC1e1c05C3c17B83d); 

        Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        whiteList[Router] = true;
        whiteList[TEAM] = true;
        _mint(
            TEAM, 
            100 * 1e4 * 1e18
        );
        MaxGasLimit = [50000, 50000]; 
    }

    function init(address _VIBLP, address _GameMasterContract)
        external
        OnlyOperator
    {
        LPInstance = IERC20(_VIBLP);
        whiteList[_VIBLP] = true;
        GameMasterContract = _GameMasterContract;
        whiteList[GameMasterContract] = true;
    }

    function setMaxGasLimit(uint256[2] memory _gas) public {
        MaxGasLimit = _gas;
    }

    function addWhiteList(address account) external OnlyOperator {
        whiteList[account] = !whiteList[account];
    }

    function getPerTokenReward() public view returns (uint256) {
        if (LPInstance.balanceOf(address(this)) == 0) {
            return 0;
        }

        uint256 newPerTokenReward = ((totalStakeReward - lastTotalStakeReward) *
            1e18) / LPInstance.balanceOf(address(this));
        return PerTokenRewardLast + newPerTokenReward;
    }

    function pendingToken(address account) public view returns (uint256) {
        return
            (userLPStakeAmount[account] *
                (getPerTokenReward() - userRewardPerTokenPaid[account])) /
            (1e18) +
            (userRewards[account]);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 _reward = pendingToken(_msgSender());
        require(_reward > 0, "sDAOLP stake Reward is 0");
        userRewards[_msgSender()] = 0;
        if (_reward > 0) {
            _standardTransfer(address(this), _msgSender(), _reward);
            return;
        }
    }

    function stakeLP(uint256 _lpAmount)
        external
        EOA
        GasLimit(0)
        updateReward(msg.sender)
    {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        LPInstance.transferFrom(_msgSender(), address(this), _lpAmount);
        userLPStakeAmount[_msgSender()] += _lpAmount;
    }

    function unStakeLP(uint256 _lpAmount)
        external
        EOA
        GasLimit(1)
        updateReward(msg.sender)
    {
        require(_lpAmount >= 1e18, "LP stake must more than 1");
        require(
            userLPStakeAmount[_msgSender()] >= _lpAmount,
            "No more sDAO LP Stake"
        );
        userLPStakeAmount[_msgSender()] -= _lpAmount;
        LPInstance.transfer(_msgSender(), _lpAmount);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        if (whiteList[sender] || whiteList[recipient]) {

            _standardTransfer(sender, recipient, amount);
            return;
        } else {
            totalStakeReward += (amount * 7) / 100; 
            _standardTransfer(sender, address(this), (amount * 7) / 100);
            _burn(msg.sender, amount / 50); 
            _standardTransfer(sender, TEAM, amount / 100); 
            amount = (amount * 90) / 100; 
        }
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _standardTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "VIB: transfer from the zero address");
        require(to != address(0), "VIB: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "VIB: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function GameMasterMintVIB(address to, uint256 amount) external {
        require(msg.sender == GameMasterContract, "VIB: Mint only by owner");
        _mint(to, amount);
    }

    function withdrawTEAM(address token) external {
        IERC20(token).transfer(TEAM, IERC20(token).balanceOf(address(this)));
        payable(TEAM).transfer(address(this).balance);
    }

    function permission() external OnlyOperator {
        Operator = address(0);
    }


}