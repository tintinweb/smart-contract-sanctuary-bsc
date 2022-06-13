/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// File: contracts/test.sol


pragma solidity ^0.8.0;




interface IBEP20 {

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SPDX-License-Identifier: Unlicense
pragma solidity ^ 0.8.4;

contract Exchange {

    // The Realtyum token 
    IBEP20 private realtyumToken;

    // Admin address of contract
    address private admin;
    string private tokenHash;

    //Balance 
    mapping (uint256=>uint256) public PackageData;


    /*╔═════════════════════════════╗
      ║           EVENTS            ║
      ╚═════════════════════════════╝*/

     event PackageAdded(
        uint256 bnbAmount,
        uint256 realtyumAmount
    );

     event ExchangeCompleted(
        uint256 amount,
        address to
    );

    /*╔═════════════════════════════╗
      ║           Modifiers         ║
      ╚═════════════════════════════╝*/

    modifier onlyAdmin(address _sender) {
        require(_sender==admin,"Only admin can call this method");
        _;
    }

    modifier validateHash(string memory _tokenHash) {
        require(
            (bytes(_tokenHash).length==bytes(tokenHash).length) &&
            (keccak256(bytes(_tokenHash)) == keccak256(bytes(tokenHash)))
        ,"TokenHash is not valid");
        _;
    }

    modifier validAmount(uint256 _amount) {
        require(_amount>0,"Amount is not valid");
        _;
    }

    /*╔═════════════════════════════╗
      ║          Constructor        ║
      ╚═════════════════════════════╝*/

    constructor(IBEP20 token) {
        realtyumToken = token;
        admin=msg.sender;
    }

    /*╔═════════════════════════════╗
      ║    Setters by admin         ║
      ╚═════════════════════════════╝*/
    //set new Admin
    function changeAdmin(address _newAdminAddress) public onlyAdmin(msg.sender){
        admin=_newAdminAddress;        
    }

    function setTokenHash(string memory _tokenHash) public onlyAdmin(msg.sender){
        tokenHash=_tokenHash;
    }

    function setrealtyumToken(IBEP20 token) public onlyAdmin(msg.sender){
        realtyumToken=token;
    }
    
    // Transfering from this account to only called by Admin
    function transferRealtyumToAdmin(address _to,uint256 _amount) public onlyAdmin(msg.sender) {
        realtyumToken.transfer(_to,_amount); 
    }

    /*╔═════════════════════════════╗
      ║            Getters          ║
      ╚═════════════════════════════╝*/
    
    function getAdminAddress() public view returns (address) {
        return admin;
    }
    /*╔═════════════════════════════╗
      ║            Helpers          ║
      ╚═════════════════════════════╝*/

    function _getPortion(uint256 _amount, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        return (_amount * (_percentage*100)) / 10000;
    }


    /*╔═════════════════════════════╗
      ║     Contract main methods   ║
      ╚═════════════════════════════╝*/

    function setPackageData( uint256 _bnbAmount, uint256 _realtyumAmount, string memory _tokenHash) 
    public validateHash(_tokenHash) {
        
        PackageData[_bnbAmount]=_realtyumAmount;
    }

    function exchangeBNB(uint256 _bnbAmount, string memory _tokenHash) 
    public payable validateHash(_tokenHash) validAmount(_bnbAmount){
        uint256 _amount = PackageData[_bnbAmount];
        require(_amount>0, "Package Data Amount is not valid");
        // check allowance
        uint256 allowance=realtyumToken.allowance(admin,address(this));
        require(allowance>=_amount,"check token allowance");
        
        //transfer amount
        (bool sent, bytes memory data) = admin.call{value: _bnbAmount}("");
        require(sent, "Failed to send Ether");

        //realtyum amount transfer
        realtyumToken.transferFrom(admin,msg.sender,_amount); 
            
        emit ExchangeCompleted(_bnbAmount, msg.sender);

    }
    
}