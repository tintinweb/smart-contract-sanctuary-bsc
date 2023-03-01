/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ICO {

        uint256 public icoPrice = 30*10**18; // tokens for 1BNB
        address public tokenAddress;
        address internal _owner;
        
        constructor(address _tokenAddress) {
            _owner = msg.sender;
            tokenAddress = _tokenAddress;
        }

        function get_tokens() public payable {
            IERC20(tokenAddress).transfer(msg.sender, msg.value*icoPrice / (10**18));
        }

        modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
        }

        function set_sale_price(uint256  _icoPrice) public onlyOwner {
            icoPrice = _icoPrice;
        }

        function withdraw_tokens() external onlyOwner {
            IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
        }
  
        function withdraw() external onlyOwner {
             payable(msg.sender).transfer(address(this).balance);
        }
}