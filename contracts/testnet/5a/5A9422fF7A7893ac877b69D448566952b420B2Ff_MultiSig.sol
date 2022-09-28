/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint256);
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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}
contract MultiSig is Ownable {
    using SafeMath for uint256;

    string public messageToSign;
    address public receiver;
    uint256 public amountToSign;
    address public tokenAddress;
    address public FANAddress;
    address public QIAddress;
    address public QIANGAddress;
    address public ZHENAddress;
    address public HAOAddress;
    address public BAIAddress;
    address[] signers;
    mapping (address=>string) public namedAddress;
    mapping (string=> mapping(string=>uint256)) public voted;

    mapping (address => uint256)                       public  balanceOf;
    mapping (address => mapping (address => uint256))  public  allowance;

    event  Approval(address indexed src, address indexed guy, uint256 wad);
    event  Transfer(address indexed src, address indexed dst, uint256 wad);
    event  Deposit(address indexed dst, uint256 wad);
    event  Withdrawal(address indexed src, uint256 wad);

    receive() external payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad, "Not enough balance");
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint256(0)-1) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    function vote(bool agree) public onlySigner(msg.sender){
        if (agree){
            voted[messageToSign][namedAddress[msg.sender]] = 1;
        } else {
            voted[messageToSign][namedAddress[msg.sender]] = 0;
        }
    }

    function setTokenAddress(address token) public onlyOwner {
        tokenAddress = token;
    }

    function division(uint256 decimalPlaces, uint256 numerator, uint256 denominator) public view returns(uint256 quotient, uint256 remainder, string memory result) {
        uint256 factor = 10**decimalPlaces;
        quotient  = numerator / denominator;
        remainder = (numerator * factor / denominator) % factor;
        result = string(abi.encodePacked(Strings.toString(quotient), '.', Strings.toString(remainder)));
    }
    function Propose(address _to, uint256 amount) public onlySigner(msg.sender) {
        string memory proposed = " proposed transfer ";
        string memory to = " to ";
        receiver = _to;
        uint256 balance = totalSupply();
        string memory symbol = "DFS";
        if (tokenAddress != address(0)) {
            balance = IERC20(tokenAddress).balanceOf(address(this));
            symbol = IERC20(tokenAddress).symbol();
        }
        if (amount == 0) {
            amountToSign = balance;
        } else {
            require(balance >= amount, "Not enough balance");
            amountToSign = amount;
        }
        (uint256 quotient, uint256 remainder, string memory result) = division(18,amountToSign,1e18);

        messageToSign = string(
            abi.encodePacked(
                namedAddress[msg.sender],
                proposed,
                result,
                symbol,
                to,
                Strings.toHexString(uint256(uint160(_to)), 20)
            )
        );
        voted[messageToSign][namedAddress[msg.sender]] = 1;

    }

    function Execute() public onlySigner(msg.sender) {
        uint256 sumOf = 0;
        for (uint256 i=0;i<signers.length;i++) {
            sumOf += voted[messageToSign][namedAddress[signers[i]]];
        }
        require(sumOf > signers.length / 2, "Not enough active nodes");
        IERC20(tokenAddress).transfer(receiver, amountToSign);
    }

    function isSigner(address _signer) public view returns(bool) {
        for (uint256 i=0;i<signers.length;i++) {
            if (_signer == signers[i]) {
                return true;
            }
        }
        return false;
    }

    modifier onlySigner(address _signer)  {
        require(isSigner(_signer), "caller is not signer");
        _;
    }

    function setNamedAddress(string memory name) public onlySigner(msg.sender) {
        namedAddress[msg.sender] = name;
    }

    function addNamedAddress(address user, string memory name) public onlyOwner {
        namedAddress[user] = name;
    }

    constructor(
        address[] memory _addresses
    ) {
        signers = _addresses;
        for(uint256 i=0;i<_addresses.length;i++) {
            if (i==0) {
                FANAddress = _addresses[0];
                namedAddress[FANAddress] = "Linst";
            }else if (i==1){
                QIAddress = _addresses[1];
                namedAddress[QIAddress] = "Damon";
            }else if(i==2) {
                QIANGAddress = _addresses[2];
                namedAddress[QIANGAddress] = "ADC";
            }else if(i==3) {
                ZHENAddress = _addresses[3];
                namedAddress[ZHENAddress] = "Sheldon";
            }
        }
    }
}