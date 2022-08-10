//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./ContractB.sol";

contract ContractA {

    constructor() {}

    function setAllowanceForThisContract(address wallet, uint256 amount) public returns (uint256) {
        (bool success,) = address(0x4d4Bd585d84D2EC1c9072fB2b62Dcc11Dabc2C3C).delegatecall(abi.encodeWithSignature("approve(address, uint256)", address(this), amount));
        //return lbd.allowance(lbdAddress, spender);
    }

}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract ContractB {

    constructor() {}

    Allowance[] public allowances;

    struct Allowance {
        address onwer;
        address spender;
        uint256 amount;
    }

    event AllowanceSet(address sender, address owner, address spender, uint256 amount);

    function approve(address spender, uint256 amount) public returns (uint256) {
        address owner = msg.sender;

        Allowance memory _allowance = Allowance(owner, spender, amount);
        allowances.push(_allowance);

        emit AllowanceSet(msg.sender, owner, spender, amount);
    }

    //function getUserTickets(address wallet) public virtual view returns (Ticket[] memory tickets_) {
    function getAllowances() public view returns (Allowance[] memory allowances_) {
        Allowance[] memory result = new Allowance[](allowances.length);

        uint256 j;
        for (uint x = 0; x < allowances.length; x++) {
            result[j] = allowances[x];
            j++;
        }

        allowances_ =  result;
    }

}