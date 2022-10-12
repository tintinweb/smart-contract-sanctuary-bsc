/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
//https://cointool.app web3 basic tools!
//
//
//  _____      _    _______          _                        
// / ____|    (_)  |__   __|        | |     /\                
//| |     ___  _ _ __ | | ___   ___ | |    /  \   _ __  _ __  
//| |    / _ \| | '_ \| |/ _ \ / _ \| |   / /\ \ | '_ \| '_ \ 
//| |___| (_) | | | | | | (_) | (_) | |_ / ____ \| |_) | |_) |
// \_____\___/|_|_| |_|_|\___/ \___/|_(_)_/    \_\ .__/| .__/ 
//                                               | |   | |    
//                                               |_|   |_|    
//
*/
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}
contract Create2ProxyEip1167Factory {
    function _create2Eip1167Proxy(address logic, bytes32 salt)
        internal
        returns (address newProxy)
    {
        bytes memory bytecode = _getEip1167ProxyInitBytecode(logic);
        assembly {
            newProxy := create2(
                0, // 0 wei
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
        }
    }

    function _createAndCall2Eip1167Proxy(
        address logic,
        bytes32 salt,
        bytes memory data
    ) internal returns (address newProxy) {
        newProxy = _create2Eip1167Proxy(logic, salt);

        if (data.length > 0) {
            (bool success, ) = newProxy.call(data);
        }
    }


    function _getEip1167ProxyAddress(
        address deployer,
        address logic,
        bytes32 salt
    ) public pure returns (address) {
        bytes32 initCodeHash = keccak256(_getEip1167ProxyInitBytecode(logic));
        return
            address(
                bytes20(
                    keccak256(
                        abi.encodePacked(hex"ff", deployer, salt, initCodeHash)
                    )
                )
            );
    }


    function _getEip1167ProxyInitBytecode(address logic)
        internal
        pure
        returns (bytes memory initBytecode)
    {
        require(logic != address(0), "ProxyFactory: ZERO_LOGIC_ADDRESS");
        bytes20 targetAddress = bytes20(logic);
        initBytecode = abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            targetAddress,
            hex"5af43d82803e903d91602b57fd5bf3"
        );
    }
}



contract CoinTool_App is  Create2ProxyEip1167Factory{
    address owner;
    mapping(address => mapping(address=>uint256)) public map;
    constructor() payable {
        owner = tx.origin;
    }

    function t(uint256[] calldata a,address b,bytes calldata data) public payable {
        require(msg.sender == tx.origin,"A");
        uint256 i = 0;
        for (i; i < a.length; i++) {
           _createAndCall2Eip1167Proxy(b,keccak256(abi.encodePacked( a[i], tx.origin )),data);
        }
        if(a[a.length-1]>map[b][msg.sender]){
            map[b][msg.sender] = a[a.length-1];
        }
    }

 

    function claimTokens(address _token) public  {
        require(owner == msg.sender);
        if (_token == address(0x0)) {
           payable (owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }

}