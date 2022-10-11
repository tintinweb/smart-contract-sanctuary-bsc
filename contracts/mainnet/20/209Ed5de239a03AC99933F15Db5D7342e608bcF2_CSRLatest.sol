/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0,address indexed token1,address pair,uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IFomo{
    function updateAmount(uint256 amount) external;
    function sendFomoRewardToWiner(address customer) external;
    function sendSurplusToMarketing() external;
}

interface IMining{
    function getOrderAmount(address customer) external view returns(uint256);
}

interface IPrevious{
    function inviter(address customer) external view returns(address);
    function inviterNum(address customer) external view returns(uint256);
}

library Set{
    struct SetInfo{
        address uniswapV2Pair01;
        address uniswapV2Pair02;
        address miningContract;
        address marketingWallet;
        address fomoContract;
        address surplus;
        uint256 priceUpdateTime;
        uint256 userUpdateTime;
        uint256 marketingUpdateTime;
        uint256 price;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using Set for Set.SetInfo;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => address)  inviter;
    mapping(address => uint256)  inviterNum;
    mapping(address => bool) public whitelist;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address[]  allTransactionUsers;
    address uniswapV2Pair01;
    address uniswapV2Pair02;
    address uniswapV2Router;
    address miningContract;
    address marketingWallet;
    address fomoContract;
    address manager;
    address previous;
    address surplus;
    uint256 priceUpdateTime;
    uint256 userUpdateTime;
    uint256 marketingUpdateTime;
    uint256 price;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function getCurrentPrice() public view returns(uint256){
        address target = IUniswapV2Pair(uniswapV2Pair01).token0();
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(uniswapV2Pair01).getReserves();
        if(reserve0 == 0 || reserve1 == 0) return 0;
        else if(address(this) == target) return uint256(reserve1) * 1e9 / uint256(reserve0);
        else return uint256(reserve0) * 1e9 / uint256(reserve0);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 order;
        if(miningContract != address(0)){
            order = IMining(miningContract).getOrderAmount(from);
        }
        uint256 fromBalance = _balances[from] - order;
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            // _balances[to] += amount;
        }
        _standardTransfer(from, to, amount);    
        _bing(from, to, amount);
        if(getCurrentPrice() > 0 && block.timestamp - priceUpdateTime >= 24 hours){
            price = getCurrentPrice();
            priceUpdateTime = block.timestamp;
        }
        userUpdateTime = block.timestamp;
        _afterTokenTransfer(from, to, amount);
    }

    function _standardTransfer(address from,address to,uint256 amount) internal{
        bool white = whitelist[from] || whitelist[to] || from == uniswapV2Router;
        bool withPrice = price - price * 20 / 100 > getCurrentPrice();
        bool sell  = to == uniswapV2Pair01 || to == uniswapV2Pair02;
        if(white) _whiteTransfer(from, to, amount);
        else if(withPrice && sell) _sellWithPrice(from, to, amount);
        else _normalOrSell(from, to, amount);
    }

    function _bing(address from,address to,uint256 amount) internal{
        bool isPurchase = from == uniswapV2Pair01 || from == uniswapV2Router || from == uniswapV2Pair02;
        bool befor = IPrevious(previous).inviter(to) != address(0);
        bool normalBing = !isContract(from) && !isContract(to) && !befor && amount >= 100e18  && !whitelist[to];
        bool purchaseBing = isPurchase && !isContract(to) && !whitelist[to] && !befor;
        if(inviter[to] == address(0)){     
            if(befor){
                inviter[to] = IPrevious(previous).inviter(to);
                inviterNum[to] = IPrevious(previous).inviterNum(to);
            } 
            if(normalBing){
                inviter[to] = from;
                inviterNum[from] = inviterNum[from] + 1;
            }
            if(purchaseBing){
                inviter[to] = marketingWallet;
                inviterNum[marketingWallet] += 1;
            }
        }
        if(amount >= 10e18){
            if(isPurchase == true && isContract(to) != true) allTransactionUsers.push(to);
            if(!isContract(from)) allTransactionUsers.push(from);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

    function _whiteTransfer(address from,address to,uint256 amount)internal{
        _balances[to] = _balances[to] + amount;
        emit Transfer(from, to, amount);
    }

    function _normalOrSell(address from,address to,uint256 amount) internal{
        _whiteTransfer(from, to, amount * 93 / 100);
        _whiteTransfer(from, fomoContract, amount * 1 / 100);
        _whiteTransfer(from, marketingWallet, amount * 1 / 100);

        _totalSupply = _totalSupply - amount * 1 / 100;
        emit Transfer(from, address(0), amount * 1 / 100);

        _sendInviterFee(from, to, amount);
        _sendFomoFee(amount * 1 / 100);
    }

    function _sellWithPrice(address from,address to,uint256 amount) internal{
        _whiteTransfer(from, to, amount * 80 / 100);
        _whiteTransfer(from, fomoContract, amount * 1 / 100);
        _whiteTransfer(from, marketingWallet, amount * 1 / 100);

        _totalSupply = _totalSupply - amount * 14 /100;
        emit Transfer(from, address(0), amount * 14 /100);

        _sendInviterFee(from, to, amount);
        _sendFomoFee(amount * 1 / 100);
    }

    function _sendInviterFee(address sender,address recipient,uint256 amount) internal{
        address loop = inviter[recipient];
        for(uint i=0; i<6; i++){
            address _loop = inviter[loop];
            if(i <= 1){
                if(loop != address(0)){
                    _whiteTransfer(sender, loop, amount * 1 / 100);
                    loop = _loop;
                }else{
                    _whiteTransfer(sender, surplus, amount * 1 / 100);
                    loop = _loop;
                } 
            }else{
                if(loop != address(0)){
                    _whiteTransfer(sender, loop, amount * 5 / 1000);
                    loop = _loop;
                }else{
                    _whiteTransfer(sender, surplus, amount * 5 / 1000);
                    loop = _loop;
                }
            }
        }
    }

    function _sendFomoFee(uint256 amount) internal{   
       
        if(fomoContract != address(0)){          
            if(block.timestamp - marketingUpdateTime >= 30 days){
                IFomo(fomoContract).sendSurplusToMarketing();
                marketingUpdateTime = block.timestamp;  
            }
            if(block.timestamp - userUpdateTime >= 24 hours && block.timestamp - marketingUpdateTime < 30 days){
                if(allTransactionUsers.length > 0){
                    address winer = allTransactionUsers[allTransactionUsers.length - 1];
                    IFomo(fomoContract).sendFomoRewardToWiner(winer);
                }    
            }
            if(amount > 0){
                IFomo(fomoContract).updateAmount(amount);
            }
        }
    }

    function getSetInfo() external view returns(Set.SetInfo memory info){
        info = Set.SetInfo(
            uniswapV2Pair01,
            uniswapV2Pair02,
            miningContract,
            marketingWallet,
            fomoContract,
            surplus,
            priceUpdateTime,
            userUpdateTime,
            marketingUpdateTime,
            price
        );
    }

}


contract CSRLatest is ERC20{
    
    constructor(address _previous,address _manager,address _marketing,address _fomo,address _surplus)ERC20("CSR_Version1.0","CSR"){
        manager = _manager;
        userUpdateTime = block.timestamp;
        marketingUpdateTime = block.timestamp;
        marketingWallet = _marketing;
        fomoContract = _fomo;
        previous = _previous;
        surplus = _surplus;
        whitelist[_fomo] = true;
        whitelist[_marketing] = true;
        whitelist[_manager] = true;
        whitelist[_surplus] = true;
        _mint(_manager, 10000000000e18);
        uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        uniswapV2Pair02 = IUniswapV2Factory(IUniswapV2Router(uniswapV2Router).factory())
            .createPair(address(this), IUniswapV2Router(uniswapV2Router).WETH());
        uniswapV2Pair01 = IUniswapV2Factory(IUniswapV2Router(uniswapV2Router).factory())
            .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);
    }

    modifier onlyOwner() {
        require(manager == msg.sender,"ERC20:not permit");
        _;
    }

    function setAddessInfo(address _fomo,address _market,address _mining,address _surplus) external onlyOwner{
        fomoContract = _fomo;
        marketingWallet = _market;
        miningContract = _mining;
        surplus = _surplus;
    }

    function addWhiteList(address customer,bool isWhite) external onlyOwner{
        whitelist[customer] = isWhite;
    }

    function updatePrice() external onlyOwner{
        priceUpdateTime = block.timestamp;
        price = getCurrentPrice();
    }

    function getLastUserAndTime() public view returns(address customer,uint256 time){
        if(allTransactionUsers.length > 0){
            customer = allTransactionUsers[allTransactionUsers.length -1];
        }
        time = userUpdateTime;
    }

    function getRecommendInfo(address customer) public view returns(address,uint256){
        return (inviter[customer],inviterNum[customer]);
    }

    function setOwner(address _owner) external onlyOwner{
        manager = _owner;
    }

}