/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract ProjectContract{
    // function charge(address token, uint amount) public{
    //     IERC20(token).transferFrom()
    // }

    function donate(address token, uint amount) public{
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function claim(address token, uint amount) public{
        IERC20(token).transferFrom(address(this), msg.sender, amount);
    }
}

contract PesPatron{
    struct Project{
        address owner;
        uint timestamp;
        uint8 fundingType;
    }

    mapping(uint => Project) public projects;
    uint public allProjectsLength;
    address public projectContractImplementation;

    event NewProject(uint id, address projectAddress);
    
    constructor(){
        
    }

    function createNewProject(uint8 _fundingType) external{
        uint _allProjectsLength = allProjectsLength;
        projects[_allProjectsLength] = Project({
            owner: msg.sender,
            timestamp: block.timestamp,
            fundingType: _fundingType
        });

        bytes memory bytecode = type(ProjectContract).creationCode;
        address newProjectAddress;
        assembly {
            newProjectAddress := create2(0, add(bytecode, 0x20), mload(bytecode), _allProjectsLength)

            if iszero(extcodesize(newProjectAddress)) {
                revert(0, 0)
            }
        }

        emit NewProject(_allProjectsLength, newProjectAddress);
        allProjectsLength++;
    }
}