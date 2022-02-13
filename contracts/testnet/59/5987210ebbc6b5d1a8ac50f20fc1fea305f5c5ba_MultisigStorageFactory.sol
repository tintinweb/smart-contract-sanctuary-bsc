/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

//SPDX-License-Identifier: UNLICENSED
//Made by Statfone, https://github.com/Statfone/Solidity/tree/main/MultisigStorage , please read the instructions before deploying the contract
pragma solidity ^0.7.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MultisigStorage {

    address public ownerAddress;
    address public sigAddress1;
    address public sigAddress2;
    address public sigAddress3;

    uint256 public sig1Lock; //1 means locked, 0 means unlocked
    uint256 public sig2Lock;
    uint256 public sig3Lock;

    constructor (address sigAddress1_, address sigAddress2_, address sigAddress3_, address owner_)  {
       sigAddress1 = sigAddress1_;
       sigAddress2 = sigAddress2_;
       sigAddress3 = sigAddress3_;
       ownerAddress = owner_;
       sig1Lock = 1;
       sig2Lock = 1;
       sig3Lock = 1;
   }
    

    modifier OwnerOnlyFunction {
        require(ownerAddress == msg.sender);
        _;
    }
    
    modifier requireSig1 {
        require(sigAddress1 == msg.sender);
        _;
    }

    modifier requireSig2 {
        require(sigAddress2 == msg.sender);
        _;
    }

    modifier requireSig3 {
        require(sigAddress3 == msg.sender);
        _;
    }

    //Here are the functions to unlock the multisig, you have to execute each function with the corresponding address to be able to withdraw tokens from the contract

    //Needed to receive gas tokens
    receive() external payable {}

    function unlockSig1() public requireSig1 {
        sig1Lock = 0;
    }

    function unlockSig2() public requireSig2 {
        sig2Lock = 0;
    }

    function unlockSig3() public requireSig3 {
        sig3Lock = 0;
    }

    //Now the function to lock the withdrawals, don't forget to execute it after a withdrawal to keep the coins inside the contract secure
    //Can only be executed by the owner address of the contract
    function lockAll() public OwnerOnlyFunction {
        sig1Lock = 1;
        sig2Lock = 1;
        sig3Lock = 1;
    }

    //Finally, the function to withdraw any token from the contract
    //The function have to be executed by the owner and the 3 sigs have to be unlocked or else it won't work
    function withdrawToken(address tokenContractAddress, uint256 amount) external OwnerOnlyFunction {
        if (sig1Lock == 0 && sig2Lock == 0 && sig3Lock == 0)
        {
            IERC20 tokenContract = IERC20(tokenContractAddress);
            tokenContract.transfer(msg.sender, amount);
        }
    }

    //The function to use if you want to withdraw gas token from the contract
    //The function have to be executed by the owner and the 3 sigs have to be unlocked or else it won't work
    function withdrawGasToken(uint256 amount) public OwnerOnlyFunction {
        if (sig1Lock == 0 && sig2Lock == 0 && sig3Lock == 0)
        {
            msg.sender.transfer(amount);
        }
    }
}
pragma solidity >=0.7.0;


contract MultisigStorageFactory {
    event MultisigStorageCreated(address storageAddress);

    function deployNewMultisigStorage(
        address sigAddress1_,
        address sigAddress2_,
        address sigAddress3_
    
    ) public returns (address) {
        MultisigStorage t = new MultisigStorage(
            sigAddress1_,
            sigAddress2_,
            sigAddress3_,
            msg.sender
        );
        emit MultisigStorageCreated(address(t));

        return address(t);
    }
}