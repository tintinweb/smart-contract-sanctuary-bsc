// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

interface BaseToken {
    function initialize(
    address owner_,
    string memory name_,
    string memory symbol_,
    uint256 totalSupply_,
    address charityAddress_,
    uint16 taxFeeBps_,
    uint16 liquidityFeeBps_,
    uint16 charityFeeBps_,
    uint16 maxTxBps_
  ) external;
}

contract TokenFactory is Ownable {

    mapping(address => address[]) public tokenGenerated;

    address payable public feeReceiver;

    address public baseToken;

    uint public fee = 0.1 ether;

    event TokenGenerated(address indexed creator, address  token);

    constructor() {
        feeReceiver = payable(_msgSender());
    }

    function generateToken(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address charityAddress_,
        uint16 taxFeeBps_,
        uint16 liquidityFeeBps_,
        uint16 charityFeeBps_,
        uint16 maxTxBps_
    )  external payable {
        // transfer fee
        require(msg.value >= fee, "Incorrect fee amount!");
        feeReceiver.transfer(msg.value);
        // clone a token
        require(baseToken != address(0), "please contact owner to set the base token address");
        address token = _clone(baseToken);
        tokenGenerated[_msgSender()].push(token);
        // initialize the token
        BaseToken tokenInstance = BaseToken(token);
        tokenInstance.initialize(_msgSender(), name_, symbol_, totalSupply_, charityAddress_, taxFeeBps_, liquidityFeeBps_, charityFeeBps_, maxTxBps_);
        // emit event
        emit TokenGenerated(_msgSender(), token);
    }

    /**
     * 
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     * 此方法来自OpenZeppelin
     */
    function _clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
   
    function setFeeReceiver(address payable newReceiver) external onlyOwner {
        require(feeReceiver != newReceiver,"new fee receiver should have a different address");
        feeReceiver = newReceiver;
    }

    function setFee(uint newFee) external onlyOwner {
        require(fee != newFee, "new fee should have a different value");
        fee = newFee;
    }

    function setBaseToken(address newBaseToken) external onlyOwner {
        require(baseToken != newBaseToken, "new base token should have a different address");
        baseToken = newBaseToken;
    }
}