/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

/**
  _____ _____ _____  _______     __   _____          _____  _____  ______ _   _ 
 |  __ \_   _/ ____|/ ____\ \   / /  / ____|   /\   |  __ \|  __ \|  ____| \ | |
 | |__) || || |  __| |  __ \ \_/ /  | |  __   /  \  | |__) | |  | | |__  |  \| |
 |  ___/ | || | |_ | | |_ | \   /   | | |_ | / /\ \ |  _  /| |  | |  __| | . ` |
 | |    _| || |__| | |__| |  | |    | |__| |/ ____ \| | \ \| |__| | |____| |\  |
 |_|   |_____\_____|\_____|  |_|     \_____/_/    \_\_|  \_\_____/|______|_| \_|

                                              


*/

pragma solidity ^0.8.4;

interface ERC20 {
    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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



abstract contract Ownable is Context {
    address public _owner;


    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}


contract ThePiggySwap is Context, ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;



        address piggies = 0xB93e4681d13095B0bC2E264F2CB22143d9fd0D53; 
    address tpg = 0x49c068BD88c26F2CAC47cC88E24c7D305Af147Ab; 
    uint256 public changefee = 10;
    uint256 public changekurs = 10;
    address public ceoAddress;
    address public ceoAddress1;


      constructor() public{
        ceoAddress=msg.sender;
        ceoAddress1=address(0xE938018dC71Fc176eaE85ce48f174AD47B540008);

    }

     

    

   
    function WithdrawlPiggy(address to, uint256 amount) public {
        require(msg.sender == ceoAddress);     
        ERC20(piggies).transfer(to, amount);
    }

    function WithdrawlTPG(address to, uint256 amount) public {
        require(msg.sender == ceoAddress);      
        ERC20(tpg).transfer(to, amount);
    }
    
    function buyTPG(uint256 amount) public {
        uint256 balance = ERC20(tpg).balanceOf(address(this));
        uint256 tpg_amount = amount;
        require(balance >= tpg_amount, "ERC20: Balance to low");

        ERC20(piggies).transferFrom(address(msg.sender), address(this), amount);

        ERC20(tpg).transferFrom(address(this), address(msg.sender), tpg_amount);        
    }

    function SET_KURS(uint256 value) external {
       require(msg.sender == ceoAddress);
        changekurs = value;
        
    }  

    function SET_CHANGEFEE(uint256 value) external {
       require(msg.sender == ceoAddress);
        changefee = value;
        
    }  



    //magic happens here
    function calculateTrade(uint256 amount) public view returns(uint256) {
        return SafeMath.div(amount,changekurs);
    }

    function supplyTPG() public view returns(uint256) {
        return ERC20(tpg).balanceOf(address(this));
    }


     mapping (address => uint256) private _balances;

      function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
       
        
        _tokenTransfer(from,to,amount);
    }

  
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
       
            _transferStandard(sender, recipient, amount);
       
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
    
        emit Transfer(sender, recipient, tAmount);
    }

   


}