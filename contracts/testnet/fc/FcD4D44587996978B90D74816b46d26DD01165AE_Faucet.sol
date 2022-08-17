// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
interface IERC20 {
    
     /**
     * @dev returns the tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
     /**
     * @dev returns the decimal places of a token
     */
    function decimals() external view returns (uint8);
    /**
     * @dev transfers the `amount` of tokens from caller's account
     * to the `recipient` account.
     *
     * returns boolean value indicating the operation status.
     *
     * Emits a {Transfer} event
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
 
}

contract Faucet {
    
    // The underlying token of the Faucet
    IERC20 token;
    IERC20 stakingToken;
    IERC20 stakingToken2;
    IERC20 empireToken;
    
    // The address of the faucet owner
    address owner;
    
    // For rate limiting
    mapping(address=>uint256) nextRequestAt;
    
    // No.of tokens to send when requested
    uint256 faucetDripAmount = 10 ether;
    
    // Sets the addresses of the Owner and the underlying token
    constructor (address _stakingToken, address _stakingToken2, address _empireToken, address _ownerAddress) public {
        stakingToken = IERC20(_stakingToken);
        stakingToken2 = IERC20(_stakingToken2);
        empireToken = IERC20(_empireToken);

        owner = _ownerAddress;
    }   
    
    // Verifies whether the caller is the owner 
    modifier onlyOwner{
        require(msg.sender == owner,"FaucetError: Caller not owner");
        _;
    }
    
    // Sends the amount of token to the caller.
    function send() external {
        require(stakingToken.balanceOf(address(this)) > 1,"FaucetError: Empty");
        require(stakingToken2.balanceOf(address(this)) > 1,"FaucetError: Empty");
        require(empireToken.balanceOf(address(this)) > 1,"FaucetError: Empty");
        require(nextRequestAt[msg.sender] < block.timestamp, "FaucetError: Try again later");
        
        // Next request from the address can be made only after 1 week         
        nextRequestAt[msg.sender] = block.timestamp + (1 weeks);
        
        stakingToken.transfer(msg.sender,faucetDripAmount);
        stakingToken2.transfer(msg.sender,faucetDripAmount);
        empireToken.transfer(msg.sender,faucetDripAmount);
    }  
    
    // Updates the underlying token address
     function setTokenAddresses(address _stakingToken, address _stakingToken2, address _empireToken) external onlyOwner {
        stakingToken = IERC20(_stakingToken);
        stakingToken2 = IERC20(_stakingToken2);
        empireToken = IERC20(_empireToken);
    }    
    
    // Updates the drip rate
     function setFaucetDripAmount(uint256 _amount) external onlyOwner {
        faucetDripAmount = _amount;
    }  
    
     // Allows the owner to withdraw tokens from the contract.
    function withdrawTokens(address _token, address _receiver, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount,"FaucetError: Insufficient funds");
        IERC20(_token).transfer(_receiver,_amount);
    }    
}