// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {IERC20} from './IERC20.sol';
import './TransferHelper.sol';

interface ITokenGen{
    function generateToken(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address owner,
        address raddr,
        address maddr,
        uint256 mbfee,
        uint256 msfee,
        address daddr,
        uint256 dbfee, 
        uint256 dsfee,
        uint256 bbbfee,
        uint256 bbsfee,
        uint256 lbfee,
        uint256 lsfee
    ) external returns(address);
}


contract TokenFactory{

    mapping(address => address[]) tokensOwned;

    address[] tokenOwners;

    address[] generator;

    uint256[] fees;

    event TokenCreated(address);

    uint256 fee;

    address owner = 0x7534F3e7e92E8aDbA1769CB87415AedCC267abf7;

    modifier onlyOwner() {
        require(msg.sender == owner , "Not owner");
        _;
    }

    function updategenerator(uint256 i, address _generator)external onlyOwner() {
        generator[i-1] = _generator;
    }

    function updatefee(uint256 i, uint256 amt)external onlyOwner(){
        fees[i] = amt;
    }

    function selectToken(bool basic, bool std, bool ab, bool liq, bool onews, bool twows ) external pure returns(uint8){
        uint8 select;
        if(basic){select=1;}
        if(std){
            if(ab){
                if(liq){
                    if(onews){
                        select = 4;
                    } else if(twows){
                        select = 5;
                    } else {
                        select = 3;
                    }
                }
                else{
                    if(onews){
                        select = 6;
                    } else if(twows){
                        select = 7;
                    } else{
                        select = 2;
                    }
                }
            } else if (liq) {
                if(onews){
                    select = 9;
                } else if (twows){
                    select = 10;
                } else {
                    select = 8;
                }
            } else {
                if(onews){
                    select = 11;
                } else if(twows){
                    select = 12;
                } else {
                    select = 0;
                }
            }
        }
        return select;
    }

    function createToken(
        uint8 sel,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        uint256 w1bfee,
        uint256 w2bfee, 
        uint256 w1sfee,
        uint256 w2sfee,
        uint256 bbbfee,
        uint256 bbsfee,
        uint256 lbfee,
        uint256 lsfee,
        address raddr,
        address w1addr,
        address w2addr
        ) public payable {

        require(msg.value == fees[sel-1], "Need deployment fee");

        require(sel>0, "invalid selection");

        address space = ITokenGen(generator[sel-1]).generateToken(name, symbol, decimals, totalSupply, msg.sender, raddr, w1addr, w1bfee, w1sfee, w2addr, w2bfee, w2sfee, 
        bbbfee, bbsfee, lbfee, lsfee);

        tokenOwners.push(msg.sender);

        tokensOwned[msg.sender].push(space);

        emit TokenCreated(space);

    }

    function rescueBNB() external onlyOwner(){
        TransferHelper.safeTransferETH(owner, address(this).balance);
    }

    function transferOwnership(address newaddr)external onlyOwner(){
        owner = newaddr;
    }

}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.15;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
  function safeApprove(
    address token,
    address to,
    uint256 value
) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeApprove: approve failed'
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeTransfer: transfer failed'
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::transferFrom: transferFrom failed'
    );
  }

  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function init(uint256 buyfee, uint256 sellfee, address , address , address) external;

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}