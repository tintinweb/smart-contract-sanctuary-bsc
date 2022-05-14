/**
 *Submitted for verification at BscScan.com on 2022-05-14
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

contract NftPledge is ERC1155Holder,Ownable {
    using Strings for uint256;
    using SafeMath for uint256;
    

    struct ProjectInfo{
        uint256 maxTime;
        uint256 accPerShare;
        uint256 tickets;
        uint256 maxMultiple;
    }

    mapping(uint256 => ProjectInfo) public projectMap;


    struct OrderInfo{
        bytes32 id;
        uint256 startTime;
        uint256 nftId;
        uint256 amount;
        uint256 multiple;
        uint256 lastTime;
    }
    mapping(address => mapping(bytes32 => OrderInfo)) public userOrder;
    mapping(address => bytes32[]) public userOrderIds;
    mapping(uint256 => uint256[]) public productivity;

    address public VLX;
    address public VLXC;
    address public wallet;
    address public NFT;

    uint256 public genesis;
    uint256 public interval;


    event Pledge(address user, bytes32 id,uint256 nftId, uint256 amount,uint256 multiple ,  uint256 totalTickets ,uint256 timestamp);
    event RePledge(address user, bytes32 id,uint256 nftId, uint256 amount, uint256 timestamp);

    event Withdrawal(address user, bytes32 id, uint256 amount , uint256 timestamp);


    constructor() ERC1155Holder() Ownable(){
        genesis = block.timestamp;
        interval = 1 * 3600;
        wallet = msg.sender;
        NFT = 0x843b6851207378399a9085B23159D705cD88Dcc7;
        VLX = 0x68aE9bb43e64b48741B3B378E0dFbfC1907A5294;
        VLXC = 0xE9bE1e46d9c25190595837437027FE4B94C88EBc;
        
        uint256 acc1 =  7 * 10 ** 17 ;
        uint256 acc2 =  24 * 10 ** 17 ;
        uint256 acc3 =  8 * 10 ** 18 ;
        uint256 acc4 =  28 * 10 ** 18 ;
        uint256 acc5 =  100 * 10 ** 18 ;
        uint256 acc6 =  150 * 10 ** 18 ;
        uint256 acc7 =  500 * 10 ** 18 ;
        uint256 acc8 =  1700 * 10 ** 18 ;
        uint256 acc9 =  2000 * 10 ** 18 ;
        uint256 acc10 =  2500 * 10 ** 18 ;
        
        
        // _setProjectMap(88801, 143 * 86400, acc1 / 86400 , 100 * 10 ** 18, 10);
        // _setProjectMap(88802, 125 * 86400, acc2 / 86400 , 300 * 10 ** 18, 10);
        // _setProjectMap(88803, 113 * 86400, acc3 / 86400 , 900 * 10 ** 18, 10);
        // _setProjectMap(88804, 79 * 86400, acc4 / 86400 , 2200 * 10 ** 18, 10);
        // _setProjectMap(88805, 70 * 86400, acc5 / 86400 , 7000 * 10 ** 18, 10);
        // _setProjectMap(88806, 50 * 86400, acc6 / 86400 , 7500 * 10 ** 18, 10);
        // _setProjectMap(88807, 45 * 86400, acc7 / 86400 , 22500 * 10 ** 18, 10);
        // _setProjectMap(88808, 40 * 86400, acc8 / 86400 , 68000 * 10 ** 18, 10);
        // _setProjectMap(88809, 34 * 86400, acc9 / 86400 , 68000 * 10 ** 18, 10);
        // _setProjectMap(88810, 27 * 86400, acc10 / 86400 , 68000 * 10 ** 18, 10);

        _setProjectMap(88801, 14 * 3600, acc1 / 86400 , 100 * 10 ** 18, 10);
        _setProjectMap(88802, 12 * 3600, acc2 / 86400 , 300 * 10 ** 18, 10);
        _setProjectMap(88803, 11 * 3600, acc3 / 86400 , 900 * 10 ** 18, 10);
        _setProjectMap(88804, 7 * 3600, acc4 / 86400 , 2200 * 10 ** 18, 10);
        _setProjectMap(88805, 7 * 3600, acc5 / 86400 , 7000 * 10 ** 18, 10);
        _setProjectMap(88806, 5 * 3600, acc6 / 86400 , 7500 * 10 ** 18, 10);
        _setProjectMap(88807, 4 * 3600, acc7 / 86400 , 22500 * 10 ** 18, 10);
        _setProjectMap(88808, 4 * 3600, acc8 / 86400 , 68000 * 10 ** 18, 10);
        _setProjectMap(88809, 3 * 3600, acc9 / 86400 , 68000 * 10 ** 18, 10);
        _setProjectMap(88810, 2 * 3600, acc10 / 86400 , 68000 * 10 ** 18, 10);

        productivity[acc1 / 86400 ].push( acc1 / 86400 );
        productivity[acc2 / 86400 ].push( acc2 / 86400 );
        productivity[acc3 / 86400 ].push( acc3 / 86400 );
        productivity[acc4 / 86400 ].push( acc4 / 86400 );
        productivity[acc5 / 86400 ].push( acc5 / 86400 );
        productivity[acc6 / 86400 ].push( acc6 / 86400 );
        productivity[acc7 / 86400 ].push( acc7 / 86400 );
        productivity[acc8 / 86400 ].push( acc8 / 86400 );
        productivity[acc9 / 86400 ].push( acc9 / 86400 );
        productivity[acc10 / 86400 ].push( acc10 / 86400 );
    
}

    function pledge(uint256 _nftId , uint256 _amount , uint256 _multiple)public{
        require(_multiple <= projectMap[_nftId].maxMultiple,"N");
        IERC20(VLX).transferFrom(msg.sender,wallet,projectMap[_nftId].tickets.mul(_multiple).mul(_amount));
        IERC1155(NFT).safeTransferFrom(msg.sender,address(this),_nftId,_amount,"");

        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                NFT,
                _nftId,
                _amount,
                _multiple
            )
        );

        userOrder[msg.sender][orderId] = OrderInfo({
            id: orderId,
            startTime: block.timestamp,
            nftId: _nftId,
            amount: _amount,
            multiple: _multiple,
            lastTime: block.timestamp   
        });          
        _addOrderIds(msg.sender,orderId);

        emit Pledge(msg.sender,orderId,_nftId,_amount,_multiple, projectMap[_nftId].tickets.mul(_multiple).mul(_amount), block.timestamp);

        calculateCurrentProductivity(projectMap[_nftId].accPerShare, block.timestamp .add(projectMap[_nftId].maxTime) );
    }

    function _addOrderIds(address _user, bytes32 _orderId)internal{
        (bool isIn, uint256 index) = firstIndexOf(userOrderIds[_user], 0);	
            if(isIn){
                userOrderIds[_user][index] = _orderId;
            }else{
                userOrderIds[_user].push(_orderId);
        }
    }

    function withdrawal(bytes32 _assetId)  public{
        uint256 fit = pendingFit(msg.sender, _assetId);
        if (fit > 0){
            userOrder[msg.sender][_assetId].lastTime = block.timestamp;
            IERC20(VLXC).transfer(msg.sender, fit);
            emit Withdrawal(msg.sender,  _assetId,  fit , userOrder[msg.sender][_assetId].lastTime);
        }
    
    }

    function rePledge(bytes32 _assetId)  public{
        require(userOrder[msg.sender][_assetId].id != 0,"order does not exist");
        uint256 nftId = userOrder[msg.sender][_assetId].nftId;
        uint256 endTime = userOrder[msg.sender][_assetId].startTime.add(projectMap[nftId].maxTime);
        require(block.timestamp >= endTime,"time is not up yet");
        withdrawal(_assetId);
        IERC1155(NFT).safeTransferFrom(
            address(this),
            msg.sender,
            nftId,
            userOrder[msg.sender][_assetId].amount,
            ""            
            );
        (bool isIn, uint256 index) = firstIndexOf(userOrderIds[msg.sender],_assetId);
        if(isIn){
            removeByIndex(msg.sender, index);
        }
        delete userOrder[msg.sender][_assetId];
        emit RePledge(msg.sender, _assetId, nftId, userOrder[msg.sender][_assetId].amount, block.timestamp);

            
    }


    function firstIndexOf(bytes32[] memory array, bytes32 key) internal pure returns (bool, uint256) {

        if(array.length == 0){
            return (false, 0);
        }

        for(uint256 i = 0; i < array.length; i++){
            if(array[i] == key){
                return (true, i);
            }
        }
        return (false, 0);
    }

    function removeByIndex(address _user, uint256 index) internal{
        require(index < userOrderIds[_user].length, "ArrayForUint256: index out of bounds");
        uint256 length = userOrderIds[_user].length;
        userOrderIds[_user][index] = userOrderIds[_user][length - 1];
        delete userOrderIds[_user][length - 1] ;
        
    }

    function pendingFit(address _user, bytes32 _assetId) public view returns(uint256){
        if( userOrder[_user][_assetId].id == 0){
            return 0;
        }
        uint256 nftId = userOrder[_user][_assetId].nftId;
        uint256 longestTime = userOrder[_user][_assetId].startTime.add(projectMap[nftId].maxTime);
        
        if(userOrder[_user][_assetId].lastTime >= longestTime){
            return 0;
        }

        if( block.timestamp <= longestTime){
            longestTime = block.timestamp;
        }

        // uint256 effectiveTime = longestTime.sub(userOrder[_user][_assetId].lastTime); 
        //uint256 fit = getMultiplier(effectiveTime, projectMap[nftId].accPerShare ,  userOrder[_user][_assetId].multiple, userOrder[_user][_assetId].amount);
        uint256 fit = getMultiplier2(userOrder[_user][_assetId].lastTime, longestTime, userOrder[_user][_assetId].multiple, userOrder[_user][_assetId].amount,projectMap[nftId].accPerShare);

        return fit;
    }


    function getMultiplier(uint256 _timestamp, uint256 _accPerShare, uint256 _multiple, uint256 amount) public pure returns(uint256){
            return _timestamp.mul(_accPerShare).mul(_multiple).mul(amount);
    }

    function getMultiplier2(uint256 _startTime, uint256 _endTime, uint256 _multiple, uint256 amount, uint256 _accPerShare) public view returns(uint256){
        
        uint256 startGap = _startTime.sub(genesis).div(interval);
        uint256 endGap = _endTime.sub(genesis).div(interval);  
        
        uint256 startMod;        
        uint256 afterGit = 0;
        if(endGap == startGap){
            startMod = _endTime.sub(_startTime.mod(genesis));            
        }else{            
            startMod = interval.sub(_startTime.mod(genesis));
            uint256 endMod = _endTime.mod(genesis);
            afterGit =  getPower(_accPerShare, endGap.sub(1) ) * endMod;
        }
        uint256 beforeGit = getPower(_accPerShare, startGap ) * startMod;
        uint256 betweenGit;
        for(uint256 i = startGap.add(1); i < endGap; i++){
            betweenGit = betweenGit.add( getPower(_accPerShare, i ) * startMod);
        }
        
        uint256 totalGit = beforeGit.add(betweenGit).add(afterGit);
        totalGit = totalGit.mul(amount).mul(_multiple);
        return totalGit;

    }


    function getPower(uint256 _accPerShare, uint256 _nonce) public view returns(uint256){            
        return productivity[_accPerShare][_nonce];
    }

    function calculateCurrentProductivity(uint256 _accPerShare, uint256 _maxTime)public{
        uint256 startGap = _maxTime.sub(genesis).div(interval).add(1);
        calculateProductivity(_accPerShare,startGap);
    }

    function calculateProductivity(uint256 _accPerShare, uint256 _nonce)public{
        
        uint256 length = productivity[_accPerShare].length;
        if(length < _nonce){
            for(uint256 i = length; i <= _nonce; i++){
            uint256 numerator = productivity[_accPerShare][length -1] * 90;
            uint256 denominator = 100;
            //if( numerator < denominator ) break;
            //productivity[_accPerShare][i] = numerator / denominator;
            productivity[_accPerShare].push( numerator / denominator) ;
            
            }
            
        }
        
    }  
    
    struct UserOrders{
        bytes32 id;
        uint256 nftId;
        uint256 amount;
        uint256 startTime;
        uint256 maxTime;
        uint256 lastTime;
        uint256 ordertickets;
        uint256 orderMultiple;
        uint256 fit;

    }

    function userOrderInfo(address _user,  uint256 page , uint256 pageSize)public view returns(UserOrders[] memory,uint256 total){		
        
        uint256 length  = userOrderIds[_user].length;
        uint256 star = page.sub(1).mul(pageSize);
        uint256 end = length > page.mul(pageSize) ? page.mul(pageSize): length;

        uint256 key ;

        bytes32 orderId;

        UserOrders[] memory userOrders = new UserOrders[](end.sub(star));

        for(uint256 i = star; i < end ; i++){
            orderId = userOrderIds[_user][i];
            
            userOrders[key].id = orderId;           
            userOrders[key].nftId = userOrder[_user][ orderId ].nftId;
            userOrders[key].amount = userOrder[_user][ orderId ].amount;
            userOrders[key].startTime = userOrder[_user][ orderId ].startTime;
            userOrders[key].maxTime = projectMap[userOrder[_user][ orderId ].nftId ].maxTime;
            userOrders[key].lastTime = userOrder[_user][ orderId ].lastTime;
            userOrders[key].ordertickets = projectMap[userOrder[_user][ orderId ].nftId ].tickets;
            userOrders[key].orderMultiple =userOrder[_user][ orderId ].multiple;
            userOrders[key].fit = pendingFit(_user, orderId);
            key++;
        }

        return (userOrders,length);
    }
    


    function setProjectMap(
        uint256 _nftId,
        uint256 _maxTime,
        uint256 _accPerShare,
        uint256 _tickets,
        uint256 _maxMultiple
        )public onlyOwner{
            _setProjectMap(_nftId,_maxTime,_accPerShare,_tickets,_maxMultiple);

    }
    
    function _setProjectMap(
        uint256 _nftId,
        uint256 _maxTime,
        uint256 _accPerShare,
        uint256 _tickets,
        uint256 _maxMultiple)internal{
            projectMap[_nftId].maxTime = _maxTime;
            projectMap[_nftId].accPerShare = _accPerShare;
            projectMap[_nftId].tickets = _tickets;
            projectMap[_nftId].maxMultiple = _maxMultiple;

    }

    function setGenesisAndInterval(uint256 _genesis, uint256 _interval)public onlyOwner{
        genesis = _genesis;
        interval = _interval;
    }

    function setProductivity(uint256 _acc, uint256 _key, uint256 _output)public onlyOwner{
        _setProductivity(_acc,_key,_output);
    }

    function _setProductivity(uint256 _acc, uint256 _key, uint256 _output)internal{
        productivity[_acc][_key] = _output;
    }

    receive() external payable {}  
    


    function withdrawalBNB() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawalTokens(IERC20 token) public onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        token.transfer(msg.sender, amount);
    }

    function withdrawalNFTAmount(IERC1155 token, uint256 _nftId) public onlyOwner {
        uint256 amount = token.balanceOf(address(this), _nftId);
        token.safeTransferFrom(address(this), msg.sender, _nftId, amount, "");
    }


}