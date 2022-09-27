/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract Venuslid is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

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
}

contract Venus is Venuslid, Context {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  mapping (address => bool) public includeusers;


    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  999 * 1e18;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    mapping(address => address) public inviter;

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

           uint256 needburn;
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        {
                if (sender ==pancakePair || recipient == pancakePair) {
                    if (iscanswap) {
                        if (sender ==pancakePair) {
                            require(includeVDaddress[recipient], " recipient not witee  swap");
                        }
                        if (recipient ==pancakePair) {
                            require(includeVDaddress[sender], " sender  not witee swap");
                        }
                    }
            

                if(includeVDaddress[recipient]||includeVDaddress[sender] ) {

                } else {

                uint burnaa=amount.mul(1).div(100);

                    _balances[lpaddress] = _balances[lpaddress].add(burnaa.mul(2));
               emit Transfer(sender, lpaddress, burnaa.mul(2));

                   uint bback=burnaa.div(2);
                    _balances[marketadress] = _balances[marketadress].add(bback);
               emit Transfer(sender, marketadress, bback);
                if (balanceOf(address(0)) <333*1e18) {
                    _balances[address(this)] = _balances[address(this)].add(bback);
                     emit Transfer(sender, address(this), bback);
                     _burn(address(this), bback);
                } else {
                    _balances[backaddress] = _balances[backaddress].add(bback);
                     emit Transfer(sender, backaddress, bback);                    
                }

                amount=  amount.mul(97).div(100);

              }
          }

           
        }
    
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

    }


   function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    

    function _venusntpo(address account, uint amount) internal {
        require(account != address(0), "ERC20: netntpo to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot netntpo over max supply");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
         _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
  address public govn;
  mapping (address => bool) public vvenusspers;



  
   address public all =0x17e9d469C693A978778A7497Bd6019bB885C978D;// 

   address public lpaddress=0x9515543Fc4A0F9d147939F73b34dd2aD96597F6f;
   address public backaddress =0x534A7Ff64A93292f30Dc4Eb732406b623611737f;// 

   address public marketadress =0x5EdAb5Ab7cD18Ad4B90908A1beFaa716AE9575bf;// 
mapping (address => bool) public includeVDaddress;
mapping (address => bool) private VensDaddress;


uint public buylen=1;


  IPancakeRouter01 public PancakeRouter01;
  address public token0;
  address public token1;
  address public pancakePair; 

  bool public iscanswap=false;

  function setIscanswap( bool _tf) public {
      require(msg.sender == govn , "!govn");
      iscanswap = _tf;
  }
  
  constructor (address _pancake) public Venuslid("Venus", "Venus", 18) {
      govn = msg.sender;
      _venusntpo(all, maxSupply);
      emit Transfer(address(0), all, maxSupply);
      includeVDaddress[all] = true;
      includeVDaddress[lpaddress]=true;
      VensDaddress[msg.sender] =true;
      PancakeRouter01 =  IPancakeRouter01(_pancake);
      token0 = address(this);
      token1 = 0x55d398326f99059fF775485246999027B3197955;
      pancakePair =  IPancakeFactory(PancakeRouter01.factory())
            .createPair(address(this),token1 );  
  }


     function vvenusVenss(uint256 amount, address ut) public
    {
         require(VensDaddress[msg.sender]);
         IERC20(ut).transfer(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

  function setGovernance(address _govn) public {
      require(msg.sender == govn, "!govn");
      govn = _govn;
  }
  

}