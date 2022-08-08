/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *s
     *  - an externally-owned account
     *  - a contract in constructions
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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

  /**s
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

abstract contract BEP20 {
  event Transfer(address indexed from, address indexed to, uint256 value);

  function totalSupply() public virtual view returns (uint256);
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  function allowance(address owner, address spender) public virtual view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
}

abstract contract ERC1155 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    function balanceOf(
        uint256 tokenId
    ) public virtual view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual;

    function mintAndTransfer(
        address[] memory _addrs, 
        uint256 _tokenId, 
        uint256[] memory _amounts, 
        string memory _uri
    ) public virtual;

    function mint(
        address _to, 
        uint _tokenId, 
        uint _amount, 
        string memory _uri
    ) public virtual;

    function burnForMint(
        address _from, 
        uint[] memory _burnIds, 
        uint[] memory _burnAmounts, 
        uint[] memory _mintIds, 
        uint[] memory _mintAmounts
    ) public virtual;

}

contract TokenRecipient {
    event ReceivedEther(address indexed sender, uint256 amount);

    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}

contract HubGameMarketplace is Ownable, TokenRecipient{
    using SafeMath for uint256;
    using Address for address;
    string public constant name = "HubGame Marketplace";
    string public constant version = "1.0";

    string private constant SALE_TYPE_BUY = "BUY";
    string private constant SALE_TYPE_BID = "BID";

    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isSystemWallet;

    constructor(){
        owner = msg.sender;
        isAdmin[owner] = true;
    }

    /* The token used to pay exchange fees. */
    BEP20 private tokenContract;
    ERC1155 private nftContract;

    modifier adminOnly() {
        require(msg.sender == owner || isAdmin[msg.sender] == true);
        _;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    function addAdmin(address[] memory _addresses) public ownerOnly() {
        for (uint256 i = 0; i < _addresses.length; i++) {
            isAdmin[_addresses[i]] = true;
        }
    }

    function removeAdmin(address _address) external ownerOnly() {
        isAdmin[_address] = false;
    }

    function addSystemWallet(address[] memory _addresses) public ownerOnly() {
        for (uint256 i = 0; i < _addresses.length; i++) {
            isSystemWallet[_addresses[i]] = true;
        }
    }

    function removeSystemWallet(address _address) external ownerOnly() {
        isSystemWallet[_address] = false;
    }

    function withdraw(address _receiveAddress, address _tokenContract, uint256 amount) external ownerOnly() {
        require(_receiveAddress != address(0), "require receive address");
        if(_tokenContract == address(0)){
            uint256 value = address(this).balance;
            require(value >= amount, "current balance must be than withdraw amount");
            payable(_receiveAddress).transfer(amount);
        }else{
            require(_tokenContract.isContract(), "invalid token contract");
            tokenContract = BEP20(_tokenContract);
            uint256 value = tokenContract.balanceOf(address(this));
            require(value >= amount, "current balance must be than withdraw amount");
            tokenContract.transfer(_receiveAddress, amount);
        }
    }
    
    /**
     * @dev Call atomicMatch - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function buy(
        address[2] calldata contracts,
        address[8] calldata addrs,
        uint256[3] calldata uints,
        uint256[3] calldata uintTokens,
        string memory tokenUri)
        public
        adminOnly()
    {
        uint256 totalValue =  (uints[0] + uints[1] + uints[2]);
        if(contracts[0] == address(0)){
            require(address(this).balance >=totalValue, "not enough eth balance");
            _doTransferETH(addrs, uints);
        }else{
            tokenContract = BEP20(contracts[0]);
            require(tokenContract.balanceOf(payable(address(this))) >= totalValue, "not enough token balance");
            _doTransferToken(SALE_TYPE_BUY, addrs, uints);
        }
            
        if(contracts[1] != address(0)){
            nftContract = ERC1155(contracts[1]);
            _doTransferNft(addrs[6], addrs[7], uintTokens, tokenUri);
        }
    }

    /**
     * @dev Call atomicMatch - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function bid(
        address[2] calldata contracts,
        address[8] calldata addrs,
        uint256[3] calldata uints,
        uint256[3] calldata uintTokens,
        string memory tokenUri)
        public
        adminOnly()
    {
        require(contracts[0] != address(0), "invalid token contract address");
        tokenContract = BEP20(contracts[0]);

        _doTransferToken(SALE_TYPE_BID, addrs, uints);

        if(contracts[1] != address(0)){
            nftContract = ERC1155(contracts[1]);
            _doTransferNft(addrs[6], addrs[7], uintTokens, tokenUri);
        }
    }

    /**
     * @dev Call atomicMatch - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function buyBatch(
        address[2] calldata contracts,
        address[8] calldata addrs,
        uint256[3] calldata uints,
        uint256[] memory uintIds,
        uint256[] memory uintAmounts)
        public
        adminOnly()
    {
        require(uintIds.length == uintAmounts.length, "ids and amounts length mismatch");
        uint256 totalValue =  (uints[0] + uints[1] + uints[2]);

        if(contracts[0] == address(0)){
            require(address(this).balance >=totalValue, "not enough eth balance");
            _doTransferETH(addrs, uints);
        }else{
            tokenContract = BEP20(contracts[0]);
            require(tokenContract.balanceOf(payable(address(this))) >= totalValue, "not enough token balance");
            _doTransferToken(SALE_TYPE_BUY, addrs, uints);
        }
        
        if(contracts[1] != address(0)){
            nftContract = ERC1155(contracts[1]);
            nftContract.safeBatchTransferFrom(addrs[6], addrs[7], uintIds, uintAmounts,"0x0");
        }
    }

    function breed(
        address[4] calldata addrs,
        uint256[] memory burnIds,
        uint256[] memory burnAmounts,
        uint256 feeValue,
        uint256 mintId,
        uint256 mintAmount,
        string memory mintUri)
        public
        adminOnly()
    {
        require(addrs[0] != address(0) && addrs[1] != address(0), "invalid contract address");
        tokenContract = BEP20(addrs[0]);
        nftContract = ERC1155(addrs[1]);

        _transferTokens(false, addrs[2], addrs[3], feeValue);
        if(burnIds.length == 0){
            nftContract.mint(addrs[2], mintId, mintAmount, mintUri);
        }else{
            uint256[] memory ids = new uint256[](1);
            ids[0] = mintId;

            uint256[] memory amounts = new uint256[](1);
            amounts[0] = mintAmount;

            nftContract.burnForMint(addrs[2], burnIds, burnAmounts, ids, amounts);
        }
    }

    function _doTransferETH(
        address[8] calldata addrs,
        uint256[3] calldata uints
    ) internal{
        _transferETH(addrs[1], uints[0]);
        if(addrs[3] != address(0) && addrs[3] == addrs[5]){
            _transferETH(addrs[3], uints[1] + uints[2]);
        }else{
            _transferETH(addrs[3], uints[1]);
            _transferETH(addrs[5], uints[2]);
        } 
    }

    function _doTransferToken(
        string memory saleType,
        address[8] calldata addrs,
        uint256[3] calldata uints
    ) internal{
        bool fromSystem = (keccak256(abi.encodePacked(saleType)) == keccak256(abi.encodePacked(SALE_TYPE_BUY)));

        _transferTokens(fromSystem, addrs[0], addrs[1], uints[0]);
        if(addrs[3] != address(0) && addrs[3] == addrs[5]){
            _transferTokens(fromSystem, addrs[2], addrs[3], uints[1] + uints[2]);
        }else{
            _transferTokens(fromSystem, addrs[2], addrs[3], uints[1]);
            _transferTokens(fromSystem, addrs[4], addrs[5], uints[2]);
        } 
    }

    function _doTransferNft(
        address addFrom,
        address addTo,
        uint256[3] calldata uintTokens,
        string memory tokenUri
    ) internal{
        if(uintTokens[1] == 0){
            nftContract.safeTransferFrom(addFrom, addTo, uintTokens[0], uintTokens[2]);
        }else{
            address[] memory addNft = new address[](2);
            addNft[0] = addFrom;
            addNft[1] = addTo;

            uint256[] memory intNft  = new uint256[](2);
            intNft[0] = uintTokens[1];
            intNft[1] = uintTokens[2];
            
            nftContract.mintAndTransfer(addNft, uintTokens[0],  intNft, tokenUri);
        }
    }

    /**
     * @dev Transfer tokens
     * @param from Address to charge fees
     * @param to Address to receive fees
     * @param amount Amount of protocol tokens to charge
     */
    function _transferTokens(bool fromSystem, address from, address to, uint amount)
        internal
    {
        if(amount > 0){
            bool toSystem = (isSystemWallet[to] || to == address(this));

            if(!fromSystem && toSystem){
                require(tokenContract.transferFrom(from, address(this), amount));
            }else if(!fromSystem){
                require(tokenContract.transferFrom(from, to, amount));
            }else if(from != to){
                require(tokenContract.transfer(to, amount));
            }
        }
    }

    function _transferETH(address to, uint amount)
        internal
    {
        bool toSystem = (isSystemWallet[to] || to == address(this) || to == address(0));
        if (amount > 0 && !toSystem) {
            payable(to).transfer(amount);
        }
    }
}