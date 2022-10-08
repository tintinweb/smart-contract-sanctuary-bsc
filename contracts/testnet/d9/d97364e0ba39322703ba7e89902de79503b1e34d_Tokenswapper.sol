/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
contract Owned {
    address public owner;
    address public proposedOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() virtual {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev propeses a new owner
     * Can only be called by the current owner.
     */
    function proposeOwner(address payable _newOwner) external onlyOwner {
        proposedOwner = _newOwner;
    }

    /**
     * @dev claims ownership of the contract
     * Can only be called by the new proposed owner.
     */
    function claimOwnership() external {
        require(msg.sender == proposedOwner);
        emit OwnershipTransferred(owner, proposedOwner);
        owner = proposedOwner;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface ERC20 {
   function balanceOf(address _owner) view external  returns (uint256 balance);
   function transfer(address _to, uint256 _value) external  returns (bool success);
   function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);
   function approve(address _spender, uint256 _value) external returns (bool success);
   function allowance(address _owner, address _spender) view external  returns (uint256 remaining);
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Tokenswapper is Context, Owned { 
    address public oldToken;
    address public newToken;
    uint256 public oldToken_amt;
    uint256 public oneOldTokenEquals = 100; 
    constructor(address oldTokens,address newTokens)  {
         owner = msg.sender;
         oldToken = oldTokens;
         newToken = newTokens;
    }
    function updateRatio(uint256 _oneOldTokenEquals) external onlyOwner{
        oneOldTokenEquals = _oneOldTokenEquals;
    }
    function exchangeToken(uint256 tokens) external{
        require(tokens <= ERC20(newToken).balanceOf(address(this)), "Not enough tokens in the reserve");
        require(ERC20(oldToken).transferFrom(_msgSender(), address(this), tokens), "Tokens cannot be transferred from user account");      
        
        ERC20(newToken).transfer(_msgSender(), (tokens * oneOldTokenEquals));
        oldToken_amt = oldToken_amt + tokens;
    }
    function extractOldTokens() external onlyOwner{
        ERC20(oldToken).transfer(_msgSender(), oldToken_amt);
        oldToken_amt = 0;
    }
    function extractNewTokens() external onlyOwner{
        ERC20(newToken).transfer(_msgSender(), ERC20(newToken).balanceOf(address(this)));
    }
}