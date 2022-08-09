/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity ^0.8.0;

interface IERC20{
    function transfer(address to, uint256 amount) external;
}

contract CrossChainMinter{
    address public owner;
    address public operator;
    IERC20 public immutable fromToken;
    IERC20 public immutable toToken;
    uint256 public immutable fromChainId;
    mapping(bytes32 => address) public mintTo;
    event CrossChainMint(bytes32 indexed burnHash, address indexed to, uint256 amount);
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Minter:only owner");
        _;
    }
    
    constructor(IERC20 _fromToken, IERC20 _toToken, uint256 _fromChainId){
        fromToken = _fromToken;
        toToken = _toToken;
        fromChainId = _fromChainId;
        owner = msg.sender;
        operator = msg.sender;
    }
    
    function setOperator(address _operator) external onlyOwner{
        operator = _operator;
    }
    
    function setOwner(address _owner) external onlyOwner{
        owner = _owner;
    }
    
    function claimToken(IERC20 _token, address to, uint256 amount) external onlyOwner{
        _token.transfer(to, amount);
    }
    
    function crossChainMint(bytes32 burnHash, address to, uint256 amount) external {
        require(msg.sender == operator, "Minter:only operator");
        require(mintTo[burnHash] == address(0), "Minter:already minted");
        toToken.transfer(to, amount);
        mintTo[burnHash] = to;
        emit CrossChainMint(burnHash, to, amount);
    }
}