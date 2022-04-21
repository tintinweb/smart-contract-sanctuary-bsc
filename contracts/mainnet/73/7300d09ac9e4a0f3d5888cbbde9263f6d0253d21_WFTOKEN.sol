/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface TokenTimelock{
    function stepAmount() external view returns (uint256);
    function beneficiary() external view returns (address);
}

contract Dapp {
    using SafeMath for uint256;
    event sendMyWFMsg(
        uint256 sendTime,
        uint256 sendAmount
    );

    address gocpPair;

    mapping (address => uint256) public userGetWFTime;
    mapping (uint256 => uint256) public gocpPollTotal;
    mapping (address => uint256) public usergocpPollTotal;
    mapping (address => address[]) spreads;

    address UnlockContract;

    uint32 public oneDay = 86400;
    uint256 public wftime = 1650470400;

    function setSpread(address _to, address _up) internal returns (uint) {
        if(spreads[_to].length == 0){
            spreads[_to].push(_up);
            if(spreads[_up].length>0){
                spreads[_to].push(spreads[_up][0]);
            }
        }
        return spreads[_to].length;
    }

    function getMyWF(address _sender) public view returns (uint256) {
        IERC20 gocpPairContent = IERC20(gocpPair);
        uint256 stepSendWF = TokenTimelock(UnlockContract).stepAmount();

        uint256 nowTime = wftime;
        if( block.timestamp > wftime.add(oneDay) ) nowTime = wftime.add(oneDay);

        uint256 Amount = 0;
        if(gocpPairContent.balanceOf(_sender)==0) return Amount;

        if(userGetWFTime[_sender] ==0){
            return gocpPairContent.balanceOf(_sender).mul(10**5).div(gocpPairContent.totalSupply()).mul(stepSendWF);
        }else{
            uint256 myAmount = usergocpPollTotal[_sender];
            for (uint i = nowTime; i > userGetWFTime[_sender]; i = i - oneDay) {
                if(i == nowTime){
                    myAmount = gocpPairContent.balanceOf(_sender);
                    Amount = Amount.add(myAmount.mul(10**5).div(gocpPairContent.totalSupply()).mul(stepSendWF));
                }else{
                    if(gocpPollTotal[i]>0){
                        Amount = Amount.add(myAmount.mul(10**5).div(gocpPollTotal[i]).mul(stepSendWF));
                    }
                }
            }
        }
        return Amount;
    }

    function computeWF(address _sender) internal returns (uint256) {
        if( block.timestamp > wftime.add(oneDay) ) {
            wftime = wftime.add(oneDay);
            gocpPollTotal[wftime] = IERC20(gocpPair).totalSupply();
        }
        require(userGetWFTime[_sender] < wftime, "Pickup time not yet");
        uint256 Amount = getMyWF(_sender);
        usergocpPollTotal[_sender] = IERC20(gocpPair).balanceOf(_sender);
        userGetWFTime[_sender] = wftime;
        return Amount;
    }

    function setWftime(uint256 _val) public{    
        require(TokenTimelock(UnlockContract).beneficiary() == msg.sender, "You don't have permission to setting");
        wftime = _val;
    }
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract WFTOKEN is Context, IERC20, Ownable, Dapp {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address payable marketingAddress;
    address public releaseAddress;
    address public fluidityAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) _balances;
    mapping (address => uint256) pollAmount;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isPoolAddress;

    address[] pollAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public newPollAddress;
    address usdtToken;
    
    uint256 public minToSwap = 500000;
    uint256 public lowBalance = 20000000000;
    uint8 private usdtWay = 0;

    event getReservesData(
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast,
        uint256 pollUsdt
    );

    constructor (
        address _gocpPair,        //0x912C6D9Ebb47B592c30035599F1917E342449a50
        address _router,          //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        address _owner,           //0x4F3FDa5116bbAec9e92073f0098BE3cfe6115589
        address _usdtToken,       //0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        address _UnlockContract,  //0x1611F713f37Aa38b3e3dAEb696171d1cB54c950a
        address _releaseAddress,   //0xa23806ed70c5318d9f5c86f619b9f76c1a2bf8e9
        address _fluidityAddress //0x65b7403B2980Ca50f7fE249E73735E30AE505ACb
    ) payable {
        _name = "FiveBlessingsChain";
        _symbol = "WF";
        _decimals = 5;
        owner = payable(_owner);
        _totalSupply = 210000 * 10 ** _decimals;

        gocpPair = _gocpPair;
        usdtToken = _usdtToken;
        UnlockContract = _UnlockContract;
        fluidityAddress = _fluidityAddress;

        releaseAddress = _releaseAddress;
        marketingAddress = payable(0xafd19A57d7a8a4FC5D43406e2e2052588972B4e9);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtToken);
        uniswapV2Router = _uniswapV2Router;

        address token0 = IUniswapV2Pair(uniswapPair).token0();
        if(token0 == address(usdtToken)){
            usdtWay = 1;
        }

        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        isMarketPair[address(uniswapPair)] = true;

        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(uniswapPair)] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketingAddress] = true;

        _balances[owner] = 127875 * 10 ** _decimals;
        _balances[_UnlockContract] = 82125 * 10 ** _decimals;
        
        emit Transfer(address(0), owner, _balances[owner]);
        emit Transfer(address(0), _UnlockContract, _balances[_UnlockContract]);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        if(address(uniswapPair) != recipient && address(uniswapPair) != sender){
            setSpread(recipient, sender);
        }
        if(amount == 0) return true;

        IUniswapV2Pair pairContent = IUniswapV2Pair(uniswapPair);

        if(newPollAddress != address(0)){
            pollAmount[newPollAddress] = pairContent.balanceOf(newPollAddress);
            delete newPollAddress;
        }

        uint112 reserve0 = 0;
        uint112 reserve1 = 0;
        uint32 blockTimestampLast = 0;
        (reserve0, reserve1, blockTimestampLast) = pairContent.getReserves();
        uint pollUsdt = IUniswapV2Pair(usdtToken).balanceOf(uniswapPair);
        emit getReservesData(reserve0, reserve1, blockTimestampLast, pollUsdt);
        uint256 reserve = usdtWay==1 ? reserve0 : reserve1;

        if(isMarketPair[recipient]) {
            if(reserve < pollUsdt){
                if(isPoolAddress[sender] == false) {
                    isPoolAddress[sender] = true;
                    pollAddress.push(sender);
                }
                newPollAddress = sender;
            }else{
                require(_balances[sender] >0, "can't sell out");
                if(isExcludedFromFee[sender]==false){
                    shareDividend(2, amount, amount.div(10), sender, sender);
                    amount = amount.sub(amount.div(10));
                }
            }
            pollAmount[sender] = pairContent.balanceOf(sender);
        }else if(isMarketPair[sender]){
            uint pollNumber = pairContent.balanceOf(recipient);
            if(pollNumber < pollAmount[recipient]){
                newPollAddress = recipient;
                if(isExcludedFromFee[recipient] == false && _balances[address(0)] < lowBalance){
                    _balances[address(0)] = _balances[address(0)].add(amount.mul(2).div(100));
                    emit Transfer(sender, address(0), amount.mul(2).div(100));
                    amount = amount.sub(amount.mul(2).div(100));
                }
            }else{
                if(isExcludedFromFee[recipient] == false){
                    shareDividend(1, amount, amount.div(10), sender, recipient);
                    amount = amount.sub(amount.div(10));
                }
            }
            pollAmount[recipient] = pollNumber;
        }else{
            if(_balances[address(this)]>minToSwap) swapTopoll();
            require(_balances[sender]>0, "can't sell out");
        }
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getWf(address _sender) public {
        uint256 amount = computeWF(_sender);
        _balances[releaseAddress] = _balances[releaseAddress].sub(amount, "Insufficient Balance");
        _balances[_sender] = _balances[_sender].add(amount);
        emit Transfer(releaseAddress, _sender, amount);
    }

    function clearThisData() public {
        IERC20(usdtToken).transfer(fluidityAddress,IERC20(usdtToken).balanceOf(address(this)));
        _balances[fluidityAddress] = _balances[fluidityAddress].add(_balances[address(this)]);
        emit Transfer(address(this), fluidityAddress, _balances[address(this)]);
        _balances[address(this)] = 0;
    }

    function swapTopoll() public {
        uint256 swapToken = minToSwap.div(2);
        if(_balances[address(this)]>=minToSwap.mul(2)) swapToken = minToSwap;
        if(_balances[address(this)]>=minToSwap.mul(4)) swapToken = minToSwap.mul(2);
        uint256 before = IERC20(usdtToken).balanceOf(uniswapPair);
        swapTokenForUsdt(swapToken,fluidityAddress);
        uint256 afterU = IERC20(usdtToken).balanceOf(uniswapPair);
        uint256 realUsdt = before.sub(afterU);
        IERC20(usdtToken).transferFrom(fluidityAddress,address(this),realUsdt);
        _approve(address(this), address(uniswapV2Router), swapToken);
        IERC20(usdtToken).approve(address(uniswapV2Router), realUsdt);
        uniswapV2Router.addLiquidity(
            address(usdtToken),
            address(this),
            realUsdt,
            swapToken,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            fluidityAddress,
            block.timestamp
        );
    }

    function swapTokenForUsdt(uint256 tokenAmount, address _to) private returns (bool) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtToken);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of TOKEN
            path,
            _to, // The contract
            block.timestamp
        );
        return true;
    }

    function shareDividend(uint8 wtype, uint256 amount, uint256 tAmount, address _from, address _to) private {
        uint256 twoPercent = amount.mul(2).div(100);
        uint256 fivePercent = amount.mul(5).div(100);
        uint256 spreadDeep = spreads[_to].length;
        uint256 pollAmountTotal = IERC20(uniswapPair).totalSupply();
        if(fivePercent > 0){
            tAmount = tAmount.sub(fivePercent);
            _balances[address(this)] = _balances[address(this)].add(fivePercent);
            emit Transfer(_from, address(this), fivePercent);
        }
        if(spreadDeep>0 && wtype == 1){
            address[] memory upAddress = spreads[_to];
            for (uint i = 0; i < spreadDeep; i++) {
                uint256 spread = i==0 ? twoPercent : twoPercent.div(2);
                if(_balances[upAddress[i]] >= 50000){
                    _balances[upAddress[i]] = _balances[upAddress[i]].add(spread);
                    emit Transfer(_from, upAddress[i], spread);
                    tAmount = tAmount.sub(spread);
                }
            }
        }
        if(twoPercent > 0 && wtype == 1 && _balances[address(0)] < lowBalance){
            tAmount = tAmount.sub(twoPercent);
            _balances[address(0)] = _balances[address(0)].add(twoPercent);
            emit Transfer(_from, address(0), twoPercent);
        }
        if(pollAmountTotal !=0  && wtype == 2){
            for (uint i = 0; i < pollAddress.length; i++) {
                uint256 myAmount = pollAmount[pollAddress[i]].mul(10**_decimals).div(pollAmountTotal).mul(fivePercent).div(10**_decimals);
                _balances[pollAddress[i]] = _balances[pollAddress[i]].add(myAmount);
                emit Transfer(_from, pollAddress[i], myAmount);
                tAmount = tAmount.sub(myAmount);
            }
        }
        if(tAmount > 0){
            _balances[marketingAddress] = _balances[marketingAddress].add(tAmount);
            emit Transfer(_from, marketingAddress, tAmount);
        }
    }
}