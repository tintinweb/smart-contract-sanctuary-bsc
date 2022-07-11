/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

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

/**
 * BEP20 standard interface.
 */
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
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
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

contract PIXMonster is IBEP20, Auth {
    using SafeMath for uint256;  
    address WBNB          = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD          = 0x000000000000000000000000000000000000dEaD;
    address ZERO          = 0x0000000000000000000000000000000000000000;
    address BUYBACK_TOKEN = 0x337C218f16dBc290fB841Ee8B97A74DCdAbfeDe8;

    uint256 feeDenominator = 10000;

    string _name = "PIX Monster";
    string _symbol = "PIX";
    uint8 _decimals = 0;

    uint256 _totalSupply = 1;

    // Info of each pool.
    struct TokenInfo {
        IBEP20 tokenAddress; 
        uint256 extraFee;
        address feeReceiver;
        bool blacklisted;
        bool transferAfter;
        bool buyBack;
        address buyBackToken;
    }
    mapping (address => TokenInfo) public tokenInfo;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    
    IDEXRouter public router;
    address public pair;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        emit Transfer(ZERO, msg.sender, _totalSupply); 
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function setTokenInfo(
        address _tokenAddress,
        uint256 _extraFee,
        address _feeReceiver,
        bool _blacklisted,
        bool _transferAfter,
        bool _buyBack,
        address _buyBackToken
        ) public onlyOwner {

        TokenInfo storage token = tokenInfo[_tokenAddress];
        token.tokenAddress = IBEP20(_tokenAddress);
        token.extraFee = _extraFee;
        token.feeReceiver = _feeReceiver;
        token.blacklisted = _blacklisted;
        token.transferAfter = _transferAfter;
        token.buyBack = _buyBack;
        token.buyBackToken = _buyBackToken;

    }    

    function transferNow(address _token, address _deliveryAddress, uint256 _amount) external swapping {
        //CHECKS CONTRACT INFO
        TokenInfo storage token = tokenInfo[_token];
        require(!token.blacklisted);
        require(IBEP20(_token).balanceOf(address(this)) >= _amount);
        uint256 amountToLiquify = _amount;
        if (_token != WBNB) {
            IBEP20(_token).transfer(address(_deliveryAddress), _amount);              
        } else {
            (bool tmpSuccess,) = payable(_deliveryAddress).call{value: amountToLiquify, gas: 30000}("");
            tmpSuccess = false;            
        }
    }

    function buyNow(address _token, address _deliveryAddress, uint256 _amountBNBToLiquify) internal swapping {
        //CHECKS CONTRACT INFO
        TokenInfo storage token = tokenInfo[_token];
        require(!token.blacklisted);
        require(address(this).balance >= _amountBNBToLiquify);

        //SET TRADING CONFIG
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        uint256 amountToLiquify = _amountBNBToLiquify;
        uint256 amountToLiquifyFee = 0;
        //CHECKS FOR EXTRA FEES & STUFF
        if (token.extraFee > 0) {
            amountToLiquifyFee = amountToLiquify.mul(token.extraFee).div(feeDenominator);
            amountToLiquify = amountToLiquify.sub(amountToLiquifyFee);
            if (!token.buyBack) {
                (bool tmpSuccess,) = payable(token.feeReceiver).call{value: amountToLiquifyFee, gas: 30000}("");
                tmpSuccess = false; 
            } else {
                buyBack(amountToLiquifyFee, token.buyBackToken, token.feeReceiver);
            }
           
        }
        address deliveryAddress = _deliveryAddress;
        if (_token != WBNB) {
            uint256 balanceBefore = IBEP20(_token).balanceOf(address(this));
            if (token.transferAfter) {
                deliveryAddress = address(this);
            }
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountToLiquify}(
                0,
                path,
                deliveryAddress,
                block.timestamp
            );
            if (deliveryAddress == address(this)) {
                uint256 balanceNow = IBEP20(_token).balanceOf(address(this));
                uint256 amountToBeSent = balanceNow.sub(balanceBefore);
                IBEP20(_token).transfer(address(_deliveryAddress), amountToBeSent);                
            }

        } else {
            (bool tmpSuccess,) = payable(_deliveryAddress).call{value: amountToLiquify, gas: 30000}("");
            tmpSuccess = false;            
        }
    }

    //HERE IS WHERE THE MAGIC HAPPENS
    function buyToken(address _tokenAddress, address _holder, uint256 _amountInBNB) external onlyOwner {
      require(_tokenAddress != _holder);
      buyNow(_tokenAddress, _holder, _amountInBNB);
    }

    function buyBack(uint256 _amountToLiquify, address _tokenAddress, address _feeReceiver) internal swapping {
        require(address(this).balance >= _amountToLiquify);
        //SET TRADING CONFIG
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokenAddress;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountToLiquify}(
            0,
            path,
            _feeReceiver,
            block.timestamp
        );        
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;            

    }

    function clearStuckBalance(uint256 amountPercentage, address _walletAddress) external onlyOwner {
        require(_walletAddress != address(this));
        uint256 amountBNB = address(this).balance;
        payable(_walletAddress).transfer(amountBNB * amountPercentage / 100);
    }

     function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(this), "Cannot be this token");
        IBEP20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}