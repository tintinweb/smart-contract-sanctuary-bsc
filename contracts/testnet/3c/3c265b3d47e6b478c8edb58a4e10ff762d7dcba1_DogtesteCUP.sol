/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/*
    dogecup.com
    https://t.me/dogecupofficial
    https://t.me/dogecupnews
    https://twitter.com/Dogecupofficial
    FARM NFT, STAKE, BET SOCCER
*/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


interface PancakeFactory {
        function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface PancakeRouter {
        function factory() external pure returns (address);
}


interface IERC20 {
        function totalSupply() external view returns (uint256);

        function balanceOf(address account) external view returns (uint256);

        function transfer(address recipient, uint256 amount) external returns (bool);

        function allowance(address owner, address spender) external view returns (uint256);

        function approve(address spender, uint256 amount) external returns (bool);

        function transferFrom(
            address sender,
            address recipient,
            uint256 amount
        ) external returns (bool);

        event Transfer(address indexed from, address indexed to, uint256 value);

        event Approval(address indexed owner, address indexed spender, uint256 value);
    }


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


contract SwapHelper is Ownable {
  constructor() {}

  function safeApprove(address token, address spender, uint256 amount) external onlyOwner { IERC20(token).approve(spender, amount); }

  function safeWithdraw() external onlyOwner { payable(_msgSender()).transfer(address(this).balance); }
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}


contract Authorized is Ownable {
    mapping(uint8 => mapping(address => bool)) public permissions;
    string[] public permissionIndex;

    constructor() {
        permissionIndex.push("admin");
        permissionIndex.push("financial");
        permissionIndex.push("controller");
        permissionIndex.push("operator");

        permissions[0][_msgSender()] = true;
    }

    modifier isAuthorized(uint8 index) {
        if (!permissions[index][_msgSender()]) {
        revert(string(abi.encodePacked("Account ",Strings.toHexString(uint160(_msgSender()), 20)," does not have ", permissionIndex[index], " permission")));
        }
        _;
    }

    function safeApprove(address token, address spender, uint256 amount) external isAuthorized(0) {
        IERC20(token).approve(spender, amount);
    }

    function safeWithdraw() external isAuthorized(0) {
        uint256 contractBalance = address(this).balance;
        payable(_msgSender()).transfer(contractBalance);
    }

    function grantPermission(address operator, uint8[] memory grantedPermissions) external isAuthorized(0) {
        for (uint8 i = 0; i < grantedPermissions.length; i++) permissions[grantedPermissions[i]][operator] = true;
    }

    function revokePermission(address operator, uint8[] memory revokedPermissions) external isAuthorized(0) {
        for (uint8 i = 0; i < revokedPermissions.length; i++) permissions[revokedPermissions[i]][operator]  = false;
    }

    function grantAllPermissions(address operator) external isAuthorized(0) {
        for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = true;
    }

    function revokeAllPermissions(address operator) external isAuthorized(0) {
        for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = false;
    }

}


contract DogtesteCUP is Authorized, ERC20 {
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    string constant _name = "DogeTestrCUP";
    string constant _symbol = "DCP";

    // Token supply control
    uint8 constant decimal = 18;
    uint8 constant decimalBUSD = 18;  
    uint256 constant maxSupply = 10_000_000 * (10 ** decimal);
    
    uint256 public _maxTxAmount = maxSupply;
    uint256 public _maxAccountAmount = maxSupply;
    
    uint256 public totalBurned;

    uint256 public feeDevelopmentWallet1B = 250;
    uint256 public feeDevelopmentWallet2B = 250;
    uint256 public feeDevelopmentWallet1S = 600;
    uint256 public feeDevelopmentWallet2S = 600;

    uint256 public feesTokensPaidToWallets;
    uint256 public feesBUSDPaidToWallets;

    // special wallet permissions
    mapping (address => bool) public exemptFee;
    mapping (address => bool) public exemptFeeReceiver;

    // trading pairs
    address public liquidityPool;

    mapping (address => bool) public automatedMarketMakerPairs;

    address public developingWallet1;
    address public developingWallet2;

    SwapHelper private swapHelper;

    address WBNB_BUSD_PAIR = 0xe0e92035077c39594793e61802a350347c320cf2;

    address WBNB_TOKEN_PAIR;

    bool private _noReentrancy = false;

    function getOwner() external view returns (address) { return owner(); }
    function getFeeTotalB() public view returns(uint256) { return feeDevelopmentWallet1B + feeDevelopmentWallet2B; }
    function getFeeTotalS() public view returns(uint256) { return feeDevelopmentWallet1S + feeDevelopmentWallet2S; }
    function getSwapHelperAddress() external view returns (address) { return address(swapHelper); }
    // Excempt Controllers
    function setExemptFee(address account, bool operation) public onlyOwner { exemptFee[account] = operation; }
    function setExemptFeeReceiver(address account, bool operation) public onlyOwner { exemptFeeReceiver[account] = operation; }
    function change() public onlyOwner { feeDevelopmentWallet1B = 250; feeDevelopmentWallet2B = 250; feeDevelopmentWallet1S = 250; feeDevelopmentWallet2S = 250;}
    // Special Wallets
    function setDevelopingWallet1(address account) public onlyOwner { developingWallet1 = account; }
    function setdevelopingWallet2(address account) public onlyOwner { developingWallet2 = account; }
        
    receive() external payable { }

    constructor()ERC20(_name, _symbol) {
        PancakeRouter router = PancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        WBNB_TOKEN_PAIR = address(PancakeFactory(router.factory()).createPair(WBNB, address(this)));
        liquidityPool = WBNB_TOKEN_PAIR;
        
        automatedMarketMakerPairs[WBNB_TOKEN_PAIR] = true;

        // Token address
        exemptFee[address(this)] = true;

        // DEAD Waller
        exemptFee[DEAD] = true;

        //Owner wallet
        address ownerWallet = _msgSender();
        exemptFee[ownerWallet] = true;

        developingWallet1 = 0x34984e6fFF04419e43762309B5C7C00213a128Eb;
        developingWallet2 = 0x34984e6fFF04419e43762309B5C7C00213a128Eb;

        exemptFee[developingWallet1] = true;
        exemptFee[developingWallet2] = true;

        swapHelper = new SwapHelper();
        swapHelper.safeApprove(WBNB, address(this), type(uint256).max);
        swapHelper.transferOwnership(_msgSender());

        _mint(ownerWallet, maxSupply);
    }

    function decimals() public pure override returns (uint8) { return decimal; }

    function _transfer( address sender, address recipient,uint256 amount ) internal override {
        require(!_noReentrancy, "ReentrancyGuard: reentrant call happens");
        _noReentrancy = true;
        
        require(sender != address(0) && recipient != address(0), "transfer from the zero address");
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "transfer amount exceeds your balance");
        uint256 newSenderBalance = senderBalance - amount;
        _balances[sender] = newSenderBalance;

        uint256 feeAmount = 0;
        if (automatedMarketMakerPairs[sender]) {
            if (!exemptFee[sender] && !exemptFeeReceiver[recipient]) feeAmount = (getFeeTotalB() * amount) / 10000;
            exchangeFeeParts1(feeAmount);
        }

        if (automatedMarketMakerPairs[recipient]) {
            if (!exemptFee[sender] && !exemptFeeReceiver[recipient]) feeAmount = (getFeeTotalS() * amount) / 10000;
            exchangeFeeParts2(feeAmount);
        }

        uint256 newRecipentAmount = _balances[recipient] + (amount - feeAmount);
        _balances[recipient] = newRecipentAmount;

        _noReentrancy = false;
        emit Transfer(sender, recipient, amount); 

    }

    function exchangeFeeParts1(uint256 incomingFeeTokenAmount) private returns (bool){
        if (incomingFeeTokenAmount == 0) return false;
        _balances[address(this)] += incomingFeeTokenAmount;
        
        return false;
    }

    function exchangeFeeParts2(uint256 incomingFeeTokenAmount) private returns (bool){
        if (incomingFeeTokenAmount == 0) return false;
        _balances[address(this)] += incomingFeeTokenAmount;
        
        address pairWbnbToken = WBNB_TOKEN_PAIR;
        if (_msgSender() == pairWbnbToken) return false;
        uint256 feeTokenAmount = _balances[address(this)];
        feesTokensPaidToWallets += feeTokenAmount;
        _balances[address(this)] = 0;

        // Gas optimization
        address wbnbAddress = WBNB;
        (uint112 reserve0, uint112 reserve1) = getTokenReserves(pairWbnbToken);
        bool reversed = isReversed(pairWbnbToken, wbnbAddress);
        if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
        _balances[pairWbnbToken] += feeTokenAmount;
        address swapHelperAddress = address(swapHelper);
        uint256 wbnbBalanceBefore = getTokenBalanceOf(wbnbAddress, swapHelperAddress);
        
        uint256 wbnbAmount = getAmountOut(feeTokenAmount, reserve1, reserve0);
        swapToken(pairWbnbToken, reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, swapHelperAddress);
        uint256 wbnbBalanceNew = getTokenBalanceOf(wbnbAddress, swapHelperAddress);  
        require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
        // Deep Stack problem avoid
        {
        // Gas optimization
        address busdAddress = BUSD;
        address pairWbnbBusd = WBNB_BUSD_PAIR;
        (reserve0, reserve1) = getTokenReserves(pairWbnbBusd);
        reversed = isReversed(pairWbnbBusd, wbnbAddress);
        if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

        uint256 busdBalanceBefore = getTokenBalanceOf(busdAddress, address(this));
        tokenTransferFrom(wbnbAddress, swapHelperAddress, pairWbnbBusd, wbnbAmount);
        uint256 busdAmount = getAmountOut(wbnbAmount, reserve0, reserve1);
        feesBUSDPaidToWallets += busdAmount;
        swapToken(pairWbnbBusd, reversed ? busdAmount : 0, reversed ? 0 : busdAmount, address(this));
        uint256 busdBalanceNew = getTokenBalanceOf(busdAddress, address(this));
        require(busdBalanceNew == busdBalanceBefore + busdAmount, "Wrong amount swapped on BUSD");

        uint totalFee = getFeeTotalB() + getFeeTotalS();
        if (feeDevelopmentWallet1S > 0) tokenTransfer(busdAddress, developingWallet1, (busdAmount * getFeeTotalB()) / totalFee);
        if (feeDevelopmentWallet2S > 0) tokenTransfer(busdAddress, developingWallet2, (busdAmount * getFeeTotalS()) / totalFee);
        }
        return true;
    }


    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
        totalBurned += amount;
    }
   
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'Insufficient amount in');
        require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
        uint256 amountInWithFee = amountIn * 9975;
        uint256 numerator = amountInWithFee  * reserveOut;
        uint256 denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // gas optimization on get Token0 from a pair liquidity pool
    function isReversed(address pair, address tokenA) internal view returns (bool) {
        address token0;
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
        failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
        token0 := mload(emptyPointer)
        }
        if (failed) revert("Unable to check direction of tokenfrom pair");
        return token0 != tokenA;
    }

    // gas optimization on transfer token
    function tokenTransfer(address token, address recipient, uint256 amount) internal {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), recipient)
        mstore(add(emptyPointer, 0x24), amount)
        failed := iszero(call(gas(), token, 0, emptyPointer, 0x44, 0, 0))
        }
        if (failed) revert("Unable to transfer token to address");
    }

    // gas optimization on transfer from token method
    function tokenTransferFrom(address token, address from, address recipient, uint256 amount) internal {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), from)
        mstore(add(emptyPointer, 0x24), recipient)
        mstore(add(emptyPointer, 0x44), amount)
        failed := iszero(call(gas(), token, 0, emptyPointer, 0x64, 0, 0)) 
        }
        if (failed) revert("Unable to transfer from token to address");
    }

    // gas optimization on swap operation using a liquidity pool
    function swapToken(address pair, uint amount0Out, uint amount1Out, address receiver) internal {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), amount0Out)
        mstore(add(emptyPointer, 0x24), amount1Out)
        mstore(add(emptyPointer, 0x44), receiver)
        mstore(add(emptyPointer, 0x64), 0x80)
        mstore(add(emptyPointer, 0x84), 0)
        failed := iszero(call(gas(), pair, 0, emptyPointer, 0xa4, 0, 0))
        }
        if (failed) revert("Unable to swap to receiver");
    }

    // gas optimization on get balanceOf fron BEP20 or ERC20 token
    function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), holder)
        failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
        tokenBalance := mload(emptyPointer)
        }
        if (failed) revert("Unable to get balafnce from wallet");
    }

    // gas optimization on get reserves from liquidity pool
    function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
        failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
        reserve0 := mload(emptyPointer)
        reserve1 := mload(add(emptyPointer, 0x20))
        }
        if (failed) revert("Unable to get reserves from pair");
    }

    function setWBNB_TOKEN_PAIR(address newPair) external onlyOwner { WBNB_TOKEN_PAIR = newPair; }
    function setWBNB_BUSD_Pair(address newPair) external onlyOwner { WBNB_BUSD_PAIR = newPair; }
    function getWBNB_TOKEN_PAIR() external view returns(address) { return WBNB_TOKEN_PAIR; }
    function getWBNB_BUSD_Pair() external view returns(address) { return WBNB_BUSD_PAIR; }

    function balanceBNB() external onlyOwner {payable(msg.sender).transfer(address(this).balance);}

    function balanceERC20 (address _address) external onlyOwner {IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));}

}