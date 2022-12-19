/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}


contract ICO {

        uint256 public icoPrice = 69*10**18; // tokens for 1BNB
        address internal _owner;
        
        constructor() {
        _owner = msg.sender;
        }

        modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
        }

        IERC20 public ZES =  IERC20(0x11915C551cF4DC5aD14d80a6d9Ea022B0ADE2246);

        function setSalePrice(uint256  _icoPrice) public onlyOwner {
         icoPrice = _icoPrice;
        }

        function claimTokens() public payable {
            ZES.transfer(msg.sender, msg.value*icoPrice / (10**18));
        }

        function withdrawZEC() external onlyOwner {
            ZES.transfer(msg.sender, ZES.balanceOf(address(this)));
        }
  
        function withdraw() external onlyOwner {
             payable(msg.sender).transfer(address(this).balance);
        }

}