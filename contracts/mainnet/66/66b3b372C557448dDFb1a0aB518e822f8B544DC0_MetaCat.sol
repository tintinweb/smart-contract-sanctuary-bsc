// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract MetaCat is Ownable, IERC20, IERC20Metadata{
    //token-param
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalDestroy;
    uint256 private _totalSurplus;
    string private _name;
    string private _symbol;
    //apply-param
    mapping(address=>address) private _parents;
    mapping(address=>bool) private _whiteList;
    //address-param
    address public _marketing = 0x79B01B0df17b3FaEAb4793bDD0Fb50b29826aFd1; // 1%
    address public _pairPool = 0x79B01B0df17b3FaEAb4793bDD0Fb50b29826aFd1;  // 2%

    address public _yuanToos = 0xc7b6670b3595859079cD2080CC5604bf41859D3e;//0x88e82023AFF20F5B3e906f9d67b2FA09fD682bEe; // 38% Yuan yu zhou (250800)
    address public _lpsToos = 0x9A792fB836d59Ae6A8051D8Dfb9c0711f399F28E;  // 20% lps(132000)
    address public _chibi = 0x8fbB764BCEa3E6bC98CE23be8F394A82752262bC;   // 15% chibi fen hong (99000)
    address public _ido = 0x553fa13562991a6B522D7Abc3F0B0047aE395601;      // 10% 5%  shizhi  jishu (99000)
    address public _fund = 0xaaA085A025B3AD27A04951f27db2AE2b0c0866fd;     // 2% 10%  kongtu shengtai (79200)

    address public _mianFee_1 = 0x79B01B0df17b3FaEAb4793bDD0Fb50b29826aFd1; // not fee addr
    address public _mianFee_2 = 0x9F4721B87D51f2232Be7735cCB6DB71885bd5FE5; // not fee addr
    address public _mianFee_3 = 0x76892dd143e6BcDa7b91E804ebf3Fdf4D7743730; // not fee addr

    //swap router
    IPancakeRouter02 public _router;
    //swap pair
    address public _pair;

    //apply-method
    function setParentMap(address recipient) private {
        if(_parents[recipient] == address(0)){
            if(msg.sender == _pair || recipient ==  _pair) return;
            if(msg.sender == recipient || msg.sender == address(0)) return;
            if(recipient == _parents[msg.sender]) return;
            _parents[recipient] = msg.sender;
        }
    }

    // get _whiteList
    function getWhiteList(address sender) public view returns(bool){
        require(sender != address(0),"BEP20: approve sender the zero address");
        return _whiteList[sender];
    }

    // set _whiteList
    function setWhiteList(address sender, bool status) external onlyOwner{
        require(sender != address(0),"BEP20: approve sender the zero address");
        _whiteList[sender] = status;
    }

    // dnamic
    function dnamicRewards(address sender, uint256 amount) private {

        address parent = _parents[sender];

        uint256 total = amount * 4 / 100;

        uint256 reward = 0;

        for (uint i = 0; i < 10; i++) {

            if(parent != address(0)){
                
                if(i == 0){//level 1
                    reward = amount * 1 / 100;
                }

                if(i == 1){//level 2
                    reward = amount * 6 / 1000;
                }

                if(i >= 2){//level 3-10
                    reward = amount * 3 / 1000;
                }

                _balances[parent] += reward;

                total -= reward;

                emit Transfer(sender, parent, reward);

                parent = _parents[parent];
            }
        }

        if(total > 0){
            emit Transfer(sender, address(0), total);
        }
        
    }
    //"1000000000000000000"
    function airdrop(address[] memory addrlist, uint256 amount) public returns(bool) {

        require(addrlist.length != 0, "BEP20: airdrop address not is empty");

        require(addrlist.length <= 50, "BEP20: airdrop address max 50");

        for(uint i = 0; i < addrlist.length; i++) {
            if(addrlist[i] != _pairPool && addrlist[i] != _marketing && addrlist[i] != _yuanToos && addrlist[i] != _lpsToos && addrlist[i] != _chibi && addrlist[i] != _ido && addrlist[i] != _fund){
                transfer(addrlist[i],amount);
            }
        }

        return true;
    }

    //token-method
    constructor(IERC20 _usdt) {

        _name = "MetaCat";

        _symbol = "MCT";

        _initWhite();

        _initMake(660000 * 10**18, 250800 * 10**18, 132000 * 10**18, 99000 * 10**18, 99000 * 10**18, 79200 * 10**18);

        //IPancakeRouter02 router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//binance PANCAKE V2 testbsc
        IPancakeRouter02 router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//binance PANCAKE V2 maintbsc
        // set the rest of the contract variables	
        _router = router;
        // Create a uniswap pair for this new token 0x55d398326f99059fF775485246999027B3197955
        _pair = IPancakeFactory(router.factory()).createPair(address(this), address(_usdt));
        // distribution dao node ido drop

    }
    
    function _initMake(uint256 amount, uint256 u_yuanToos, uint256 u_lpsToos, uint256 u_chibi, uint256 u_ido, uint256 u_fund) private {
        _totalSupply = amount;
        _totalSurplus = amount - (6666 * 10**18);
        _balances[_yuanToos] = u_yuanToos;
        emit Transfer(address(0), _yuanToos, u_yuanToos);
        _balances[_lpsToos] = u_lpsToos;
        emit Transfer(address(0), _lpsToos, u_lpsToos);
        _balances[_chibi] = u_chibi;
        emit Transfer(address(0), _chibi, u_chibi);
        _balances[_ido] = u_ido;
        emit Transfer(address(0), _ido, u_ido);
        _balances[_fund] = u_fund;
        emit Transfer(address(0), _fund, u_fund);
    }

    function _initWhite() private{
        _whiteList[_yuanToos] = true;
        _whiteList[_lpsToos] = true;
        _whiteList[_chibi] = true;
        _whiteList[_ido] = true;
        _whiteList[_fund] = true;
        _whiteList[_mianFee_1] = true;
        _whiteList[_mianFee_2] = true;
        _whiteList[_mianFee_3] = true;
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

    function totalDestroy() public view virtual returns (uint256) {
        return _totalDestroy;
    }

    function getParentMap(address spender) public view virtual override returns (address) {
        return _parents[spender];
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //to recieve ETH from swapV2Router when swaping
    receive() external payable {}

    function withdraw() payable public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawCoin(address recipient) public onlyOwner {
        uint256 amount = balanceOf(address(this));
        _transfer(address(this), recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        setParentMap(recipient);
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        bool is_fee = true;

        if(_whiteList[sender] || _whiteList[recipient]){
            is_fee = false;
        }
        
        if(is_fee){
            // 1% marketing
            uint256 marketingAmount =  (amount*1/100);
            _balances[_marketing] += marketingAmount;
            emit Transfer(sender, _marketing, marketingAmount);
            // 2% lp
            uint256 pairPoolAmount =  (amount*2/100);
            _balances[_pairPool] += pairPoolAmount;
            emit Transfer(sender, _pairPool, pairPoolAmount);
            // 4% share
            if(recipient == _pair){
                dnamicRewards(sender, amount);
            }else{
                dnamicRewards(tx.origin, amount);
            }
            // 1% destroy - 6666
            uint256  destroyAmount = (amount*1/100);
            uint256  surplusAmount = _totalSurplus - _totalDestroy;
            if(destroyAmount > surplusAmount){
                destroyAmount = surplusAmount;
            }
            uint256 recipientAmount =  (amount*92/100);
            if(destroyAmount > 0){
                _totalSupply = _totalSupply - destroyAmount;
                _totalDestroy = _totalDestroy + destroyAmount;
                emit Transfer(sender, address(0), destroyAmount);
            }else{
                recipientAmount =  (amount*93/100);
            }
            // 92% surplus
            _balances[recipient] += recipientAmount;
            emit Transfer(sender, recipient, recipientAmount);
        }else{
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }

        //add to lps
        if(_balances[_pairPool] >= 100 * 10**18){
            _balances[_pair] += _balances[_pairPool];
            emit Transfer(_pairPool, _pair, _balances[_pairPool]);
            _balances[_pairPool]=0;
            IPancakePair(_pair).sync();
        }

    }

}