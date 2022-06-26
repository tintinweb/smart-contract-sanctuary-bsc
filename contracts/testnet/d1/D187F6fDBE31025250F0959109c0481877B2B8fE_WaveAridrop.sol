/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



contract Ownable {
    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
    
    
    /**
     * Constructor assigns ownership to the address used to deploy the contract.
     * */
    constructor() {
        owner = msg.sender;
    }


    function getOwner() public view returns(address) {
        return owner;
    }


    /**
     * Any function with this modifier in its method signature can only be executed by
     * the owner of the contract. Any attempt made by any other account to invoke the 
     * functions with this modifier will result in a loss of gas and the contract's state
     * will remain untampered.
     * */
    modifier onlyOwner {
        require(msg.sender == owner, "Function restricted to owner of contract");
        _;
    }

    /**
     * Allows for the transfer of ownership to another address;
     * 
     * @param _newOwner The address to be assigned new ownership.
     * */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0)
            && _newOwner != owner 
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



/**
 * Contract acts as an interface between the DappleAirdrops contract and all ERC20 compliant
 * tokens. 
 * */
abstract contract ERCInterface {
    function transferFrom(address _from, address _to, uint256 _value) public virtual;
    function balanceOf(address who)  public virtual returns (uint256);
    function allowance(address owner, address spender)  public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns(bool);
}



contract WaveAridrop is Ownable {
    
    using SafeMath for uint256;


    mapping (address => bool) public isPremiumMember;
        
    uint256 public premiumMemberFee;
    uint256 public rate;
    uint256 public dropUnitPrice;


    event TokenAirdrop(address indexed by, address indexed tokenAddress, uint256 totalTransfers);
    event BnbAirdrop(address indexed by, uint256 totalTransfers, uint256 ethValue);


   
    event RateChanged(uint256 from, uint256 to);
    event RefundIssued(address indexed to, uint256 totalWei);
    event ERC20TokensWithdrawn(address token, address sentTo, uint256 value);
    event CommissionPaid(address indexed to, uint256 value);
    event NewPremiumMembership(address indexed premiumMember);
    event NewAffiliatePartnership(address indexed newAffiliate, string indexed affiliateCode);
    event AffiliatePartnershipRevoked(address indexed affiliate, string indexed affiliateCode);
    event PremiumMemberFeeUpdated(uint256 newFee);

    
    constructor() {
        rate = 10000;
        dropUnitPrice = 1e14; 
        premiumMemberFee = 25e16;
    }
    

    /**
     * Allows the owner of this contract to change the fee for users to become premium members.
     * 
     * @param _fee The new fee.
     * 
     * @return True if the fee is changed successfully. False otherwise.
     * */
    function setPremiumMemberFee(uint256 _fee) public onlyOwner returns(bool) {
        require(_fee > 0 && _fee != premiumMemberFee);
        premiumMemberFee = _fee;
        emit PremiumMemberFeeUpdated(_fee);
        return true;
    }
    

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


    /**
    * Used to give change to users who accidentally send too much ETH to payable functions. 
    *
    * @param _price The service fee the user has to pay for function execution. 
    **/
    function giveChange(uint256 _price) internal {
        if(msg.value > _price) {
            uint256 change = msg.value.sub(_price);
            payable(msg.sender).transfer(change);
        }
    }


    /**
    * Allows the owner of this contract to grant users with premium membership.
    *
    * @param _addr The address of the user who is being granted premium membership.
    *
    * @return True if premium membership is granted successfully. False otherwise. 
    **/
    function grantPremiumMembership(address _addr) public onlyOwner returns(bool) {
        require(!isPremiumMember[_addr], "Is already premiumMember member");
        isPremiumMember[_addr] = true;
        emit NewPremiumMembership(_addr);
        return true; 
    }


    /**
    * Allows users to become premium members.
    *
    * @return True if user successfully becomes premium member. False otherwise. 
    **/
    function becomePremiumMember() public payable returns(bool) {
        require(!isPremiumMember[msg.sender], "Is already premiumMember member");
        require(
            msg.value >= premiumMemberFee,
            string(abi.encodePacked(
                "premiumMember fee is: ", uint2str(premiumMemberFee), ". Not enough Funds sent. ", uint2str(msg.value)
            ))
        );
        
        isPremiumMember[msg.sender] = true;

        giveChange(premiumMemberFee);
        
        payable(owner).transfer(premiumMemberFee);
        emit NewPremiumMembership(msg.sender);
        return true; 
    }
    
    /**
     * Allows for the price of drops to be changed by the owner of the contract. Any attempt made by 
     * any other account to invoke the function will result in a loss of gas and the price will remain 
     * untampered.
     * 
     * @return true if function executes successfully, false otherwise.
     * */
    function setRate(uint256 _newRate) public onlyOwner returns(bool) {
        require(
            _newRate != rate 
            && _newRate > 0
        );
        emit RateChanged(rate, _newRate);
        rate = _newRate;
        uint256 eth = 1 ether;
        dropUnitPrice = eth.div(rate);
        return true;
    }
    
    

    /**
     * Allows for the allowance of a token from its owner to this contract to be queried. 
     * 
     * As part of the ERC20 standard all tokens which fall under this category have an allowance 
     * function which enables owners of tokens to allow (or give permission) to another address 
     * to spend tokens on behalf of the owner. This contract uses this as part of its protocol.
     * Users must first give permission to the contract to transfer tokens on their behalf, however,
     * this does not mean that the tokens will ever be transferrable without the permission of the 
     * owner. This is a security feature which was implemented on this contract. It is not possible
     * for the owner of this contract or anyone else to transfer the tokens which belong to others. 
     * 
     * @param _addr The address of the token's owner.
     * @param _addressOfToken The contract address of the ERC20 token.
     * 
     * @return The ERC20 token allowance from token owner to this contract. 
     * */
    function getTokenAllowance(address _addr, address _addressOfToken) public view returns(uint256) {
        ERCInterface token = ERCInterface(_addressOfToken);
        return token.allowance(_addr, address(this));
    }
    
    
    fallback() external payable {
        revert();
    }


    receive() external payable {
        revert();
    }
    
    
    /**
    * Checks if two strings are the same.
    *
    * @param _a String 1
    * @param _b String 2
    *
    * @return True if both strings are the same. False otherwise. 
    **/
    function stringsAreEqual(string memory _a, string memory _b) internal pure returns(bool) {
        bytes32 hashA = keccak256(abi.encodePacked(_a));
        bytes32 hashB = keccak256(abi.encodePacked(_b));
        return hashA == hashB;
    }

    
    function _getTotalBnbValue(uint256[] memory _values) internal pure returns(uint256) {
        uint256 totalVal = 0;
        for(uint i = 0; i < _values.length; i++) {
            totalVal = totalVal.add(_values[i]);
        }
        return totalVal;
    }
    
    /**
     * Allows for the distribution of a token to be transferred to multiple recipients at 
     * a time. This function facilitates batch transfers of differing values (i.e., all recipients
     * can receive different amounts of tokens).
     * 
     * @param _addressOfToken The contract address of an ERC20 token.
     * @param _recipients The list of addresses which will receive tokens. 
     * @param _values The corresponding values of tokens which each address will receive.
     * 
     * @return true if function executes successfully, false otherwise.
     * */    
    function multiAirdrop(address _addressOfToken,  address[] memory _recipients, uint256[] memory _values) public payable returns(bool) {
        ERCInterface token = ERCInterface(_addressOfToken);
        require(_recipients.length == _values.length, "Total number of recipients and values are not equal");

        uint256 price = _recipients.length.mul(dropUnitPrice);

        require(
            msg.value >= price || isPremiumMember[msg.sender],
            "Not enough funds sent with transaction!"
        );

        giveChange(price);
        
        for(uint i = 0; i < _recipients.length; i++) {
            if(_recipients[i] != address(0) && _values[i] > 0) {
                token.transferFrom(msg.sender, _recipients[i], _values[i]);
            }
        }

        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }
    

    /**
     * @param _addressOfToken The contract address of a token.
     * @param _recipient The address which will receive tokens. 
     * @param _value The amount of tokens to refund.
     * 
     * @return true if function executes successfully, false otherwise.
     * */  
    function withdrawStuckTokens(address _addressOfToken,  address _recipient, uint256 _value) public onlyOwner returns(bool){
        require(
            _addressOfToken != address(0)
            && _recipient != address(0)
            && _value > 0
        );
        ERCInterface token = ERCInterface(_addressOfToken);
        token.transfer(_recipient, _value);
        emit ERC20TokensWithdrawn(_addressOfToken, _recipient, _value);
        return true;
    }
}