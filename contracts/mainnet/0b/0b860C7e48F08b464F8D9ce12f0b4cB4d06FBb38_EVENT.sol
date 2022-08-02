/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.8.15;

contract EVENT is IERC20, Ownable {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) public isAMM;
    //Token Info
    string public constant name = "MetaEvent";
    string public constant symbol = "EVENT";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 500000000 * 10**decimals;

    //TestNet
    //address private constant router=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //MainNet
    address private constant router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private pair;
    IDEXRouter private _router;
    uint256 public buyTax = 1000;
    uint256 public sellTax = 1000;
    uint256 public transferTax = 0;
    uint256 constant TAX_DENOMINATOR = 10000;
    uint256 constant MAXTAX = 2500;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        _router = IDEXRouter(router);

        //Creates a Pair
        pair = IDEXFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        isAMM[pair] = true;

        excludedFromFees[msg.sender] = true;
        excludedFromFees[address(this)] = true;
        _approve(address(this), address(_router), type(uint256).max);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        if (excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else {
            require(
                block.timestamp > LaunchTimestamp,
                "trading not yet enabled"
            );
            _taxedTransfer(sender, recipient, amount);
        }
    }

    function _taxedTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        bool isBuy = isAMM[sender];
        bool isSell = isAMM[recipient];

        uint256 tax;
        if (isSell) tax = sellTax;
        else if (isBuy) tax = buyTax;
        else tax = transferTax;

        if ((sender != pair) && (!_inSwap)) _swapContractToken();

        uint256 taxedTokens = (amount * tax) / TAX_DENOMINATOR;
        uint256 taxedAmount = amount - taxedTokens;

        balanceOf[sender] -= amount;
        balanceOf[address(this)] += taxedTokens;
        balanceOf[recipient] += taxedAmount;

        emit Transfer(sender, recipient, taxedAmount);
    }

    //Feeless transfer only transfers and autostakes
    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    bool private _inSwap;
    modifier lockTheSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }
    uint256 public swapThreshold = 15;

    function setSwapThreshold(uint256 newSwapThreshold) public onlyOwner {
        require(newSwapThreshold <= 100 && newSwapThreshold > 0);
        swapThreshold = newSwapThreshold;
    }

    event OnSetTaxes(uint256 buy, uint256 sell, uint256 transfer_);

    function setTaxes(
        uint256 buy,
        uint256 sell,
        uint256 transfer_
    ) public onlyOwner {
        require(
            buy <= MAXTAX && sell <= MAXTAX && transfer_ <= MAXTAX,
            "Tax exceeds maxTax"
        );

        buyTax = buy;
        sellTax = sell;
        transferTax = transfer_;

        emit OnSetTaxes(buy, sell, transfer_);
    }

    function _swapContractToken() private lockTheSwap {
        uint256 tokenToSwap = (balanceOf[pair] * swapThreshold) /
            TAX_DENOMINATOR;
        if (balanceOf[address(this)] < tokenToSwap) return;
        _swapTokenForBNB(tokenToSwap);
    }

    function _swapTokenForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            owner(),
            block.timestamp
        );
    }

    function SetAMM(address AMM, bool Add) public onlyOwner {
        require(AMM != pair, "can't change main router");
        isAMM[AMM] = Add;
    }

    event OnExcludeAccount(address account, bool exclude);

    function excludeAccountFromFees(address account, bool exclude)
        external
        onlyOwner
    {
        require(account != address(this), "can't Include the contract");
        excludedFromFees[account] = exclude;
        emit OnExcludeAccount(account, exclude);
    }

    event OnSetLaunchTimestamp(uint256 timestamp);
    uint256 public LaunchTimestamp = type(uint256).max;

    function launch() external {
        setLaunchTimestamp(block.timestamp);
    }

    function setLaunchTimestamp(uint256 timestamp) public onlyOwner {
        require(block.timestamp < LaunchTimestamp, "AlreadyLaunched");
        LaunchTimestamp = timestamp;
        emit OnSetLaunchTimestamp(timestamp);
    }

    receive() external payable {
        require(msg.sender == address(_router));
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}