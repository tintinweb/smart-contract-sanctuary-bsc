/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function mint(address account, uint amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function mint(uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7; 
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }


    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

interface IERC1155 is IERC165 {
    
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);


    function nftPower(uint256 _nftId) external view returns(uint256);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function mint(
         address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    )external;

     function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;
}
interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
    * @dev Converts a `uint256` to its ASCII `string` decimal representation.
    */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
    * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
    */
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

    /**
    * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
    */
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
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    mapping(address => bool) public manager;

    event OwnershipTransferred(address indexed newOwner, bool isManager);


    constructor() {
        _setManager(_msgSender(), true);
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(manager[_msgSender()] || _owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function owner() public view returns (address) {
        return _owner;
    }

    function setManager(address newOwner,bool isManager) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setManager(newOwner,isManager);
    }

    function _setManager(address newOwner, bool isManager) private {
        manager[newOwner] = isManager;
        emit OwnershipTransferred(newOwner, isManager);
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CompositeNFT is ERC1155Holder,Ownable {
    using Strings for uint256;
    using SafeMath for uint256;
    using Address for address;
    
    struct NftInfo{
        bool isEnable;
        uint256 nextLevel;
    }

    mapping (uint256 => NftInfo) public nftMap;

    struct UpgradeInfo{
        bool status;
        uint256 rate;
        uint256 cardAmount;
        uint256 HydroDAOAmount;
    }
	
    mapping(uint256 => UpgradeInfo) public upgradeMap;


    uint256 public nonce;
    address public HydroDAO;
    address public wallet;
    address public VBNFT;
    address public burnAddress;

    mapping(address => bool) public isExcluded;
	mapping(address => bool) public isBlackList;

  
    event Composite(address user,bool isSucces,uint256 HydroDAOAmount, uint256 nextLevel);

    modifier defense() {
		require(!isBlackList[msg.sender], "Address: call to hack");
        if(address(msg.sender).isContract()){
            require(isExcluded[msg.sender] , "Address: call to non-contract");     
			
        }
        _;
    }



    constructor() ERC1155Holder() Ownable(){

        wallet = 0x4dfd944d35e2c25b3a380A53Ae6Ea2687361f523;
        VBNFT = 0x13C9679E972961C555fe00C95c9de0D5E813423a;
        burnAddress = 0x000000000000000000000000000000000000dEaD;
        HydroDAO = 0x8131c0302BCF3aE3EF03986514A6bd8555791cC2;

        _setNftMap(88801,true,88802);
        _setNftMap(88802,true,88803);
        _setNftMap(88803,true,88804);
        _setNftMap(88804,true,88805);
        _setNftMap(88805,true,88806);
        _setNftMap(88806,true,88807);
        _setNftMap(88807,true,88808);
        _setNftMap(88808,true,88809);
        _setNftMap(88809,true,88810);
        _setNftMap(88810,true,88811);

        _setUpgradeMap(88802,true,100,3,0);
        _setUpgradeMap(88803,true,100,3,0);
        _setUpgradeMap(88804,true,100,3,500 * 10 ** 18);
        _setUpgradeMap(88805,true,100,3,1000 * 10 ** 18);
        _setUpgradeMap(88806,true,100,3,2000 * 10 ** 18);
        _setUpgradeMap(88807,true,90,3,4000 * 10 ** 18);
        _setUpgradeMap(88808,true,80,3,6000 * 10 ** 18);
        _setUpgradeMap(88809,true,70,3,8000 * 10 ** 18);
        _setUpgradeMap(88810,true,60,3,10000 * 10 ** 18);

    }

    function compositeBatch(uint256 _nftId, uint256 _nonce) public  defense{
        for(uint256 i = 0; i < _nonce; i++){
            composite(_nftId);
        }
    }

    function composite(uint256 _nftId)public defense{
      
        uint256 nextLevel = nftMap[_nftId].nextLevel;

        require(upgradeMap[nextLevel].status,"Upgrade not allowed");

       
       
        if( upgradeMap[nextLevel].HydroDAOAmount > 0){
            IERC20(HydroDAO).transferFrom(msg.sender,address(this),upgradeMap[nextLevel].HydroDAOAmount);
            IERC20(HydroDAO).transfer(burnAddress,upgradeMap[nextLevel].HydroDAOAmount.div(2));
            IERC20(HydroDAO).transfer(wallet,upgradeMap[nextLevel].HydroDAOAmount.div(2));
        }


        uint256 randId = randomNum(1,100);
        if(randId <= upgradeMap[nextLevel].rate){     
            IERC1155(VBNFT).burn(msg.sender,_nftId,upgradeMap[nextLevel].cardAmount);    
            IERC1155(VBNFT).mint(msg.sender,nextLevel,1,"");

            emit Composite(msg.sender, true,upgradeMap[nextLevel].HydroDAOAmount,nextLevel); 
            
        }else{
            emit Composite(msg.sender, false,upgradeMap[nextLevel].HydroDAOAmount,nextLevel);   
        }
       
    }


    function randomNum(uint256 _min, uint256 _max)internal returns(uint256) {
        uint256 index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % _max;   
        nonce++;
        return index.add(_min);
    }



    function setWallet(address _wallet)public onlyOwner{
        wallet = _wallet;
    }

    function setBurnAddress(address _burnAddress)public onlyOwner{
        burnAddress = _burnAddress;
    }

    function setVBNFT(address _VBNFT)public onlyOwner{
        VBNFT = _VBNFT;
    }

    function setHydroDAO(address _HydroDAO)public onlyOwner{
        HydroDAO = _HydroDAO;
    }

    function setUpgradeMap(uint256 _level, bool _status, uint256 _rate, uint256 _cardAmount, uint256 _HydroDAOAmount)public onlyOwner {
       _setUpgradeMap(_level,_status,_rate,_cardAmount,_HydroDAOAmount);
    }
    
    function _setUpgradeMap(uint256 _level, bool _status, uint256 _rate, uint256 _cardAmount, uint256 _HydroDAOAmount)internal {
        upgradeMap[_level].status = _status;
        upgradeMap[_level].rate = _rate;
        upgradeMap[_level].cardAmount = _cardAmount;
        upgradeMap[_level].HydroDAOAmount = _HydroDAOAmount;

    }

    function _setNftMap(uint256 _nftId, bool _isEnable, uint256 _nextLevel)internal{
        nftMap[_nftId].isEnable = _isEnable;
        nftMap[_nftId].nextLevel = _nextLevel;
    }

    function setExcluded(address _addr, bool _status) public onlyOwner{
        isExcluded[_addr] = _status;
    }
	
	function setBlackList(address _addr, bool _status) public onlyOwner{
        isBlackList[_addr] = _status;
    }

    receive() external payable {}  
    
    function withdrawalBNB() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

	function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function withdrawalNFTAmount(IERC1155 token, uint256 _nftId) public onlyOwner {
        uint256 amount = token.balanceOf(address(this), _nftId);
        token.safeTransferFrom(address(this), msg.sender, _nftId, amount, "");
    }


}