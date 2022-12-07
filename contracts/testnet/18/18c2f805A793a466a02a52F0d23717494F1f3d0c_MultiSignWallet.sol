/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: auTech;

pragma solidity ^0.8.7;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function power(uint256 a,uint p) internal pure returns (uint256) {
        uint res = 1;
        while(p != 0) {
            if(p & 1 == 1) {
                res = res * a;
            }
            p >>= 1;
            a = a * a;
        }
    return res;
}

}

contract MultiSignWallet {

    event SubmitTransaction(uint transactionId);
    event ConfirmTransaction(uint transactionId);
    event ExecuteTransaction(uint transactionId);


    using SafeMath for uint;
    
    enum TransactionMethod { Pass, SwitchExchange, SetProductionLimit, SetNextProduction, SetPoolDistributeProportion, AllowSupportedAddress, RemoveSupportedAddressAllow, ConfigurePoolAutoAddress, WithdrawToken, Distribute, SetContractOwner, FreezeAddress, BurnFreezeAddressCoin, Mint, AddAdmin, RemoveAdmin, AddSuperAdmin, RemoveSuperAdmin, ChangeAccountStakeExpirationTimestamp }

    enum Status { Pending, Executed }

    enum AdminType { None, Super, Commmon}

    uint transactionId = 0;

    struct Transaction {
        address targetAddress;
        bytes data;
        uint8 transactionType;
        uint8 status;
    }

    address[] superAdmins = new address[](1);

    address[] admins = new address[](1);

    mapping(address => uint) public superAdminIndex;

    mapping(address => uint) public adminIndex;

    mapping(address => uint8) public adminType;

    mapping(bytes4 => uint8) transactionFunctionType;

    mapping(uint => mapping(address => uint)) public transactionConfirm;

    mapping(uint => uint) public transactionSuperAdminConfirmCount;

    mapping(uint => uint) public transactionAdminConfirmCount;

    mapping(uint => uint) transactionMethodNeedAdminConfirm;

    mapping(uint => uint) transactionMethodNeedSuperAdminConfirm;

    mapping(uint => Transaction) transactionMap;

    modifier onlySelf() {
        //require(msg.sender == address(this),'Forbidden');
        _;
    }

    function submitTransaction(address targetAddress,bytes memory data) external returns (uint){
        bytes4 method = inputDataDecode(data);
        uint8 thisTransactionType = transactionFunctionType[method];
        require(thisTransactionType > 0,'Exception call');
        Transaction memory transaction = Transaction(targetAddress,data,thisTransactionType,uint8(Status.Pending));
        uint thisTransactionId = transactionId;
        transactionId = transactionId.add(1);
        transactionMap[thisTransactionId] = transaction;
        confirmTransaction(thisTransactionId);
        emit SubmitTransaction(thisTransactionId);
        return thisTransactionId;
    }
    
    function inputDataDecode(bytes memory data) pure public returns (bytes4) {
        bytes memory data2 = new bytes(data.length);
        bytes4 method = data[0] | bytes4(data[1]) >> 8 | bytes4(data[2]) >> 16 | bytes4(data[3]) >> 24;
        for (uint256 i=0; i < data.length - 4; ) {
            data2[i] = data[i + 4];
            unchecked {++i;}
        }
        //string memory str) = abi.decode(data2,(string));
        return method;
    }

    function viewTransaction(uint viewTransactionId) view public returns (Transaction memory) {
        return transactionMap[viewTransactionId];
    }

    function confirmTransaction(uint confirmTransactionId) public {
        require(transactionConfirm[confirmTransactionId][msg.sender] == 0,'Repeat confirm');
        transactionConfirm[confirmTransactionId][msg.sender] = 1;
        require(adminType[msg.sender]>0,'exception call');
        if(adminType[msg.sender] == uint8(AdminType.Super)) {
            transactionSuperAdminConfirmCount[confirmTransactionId] = transactionSuperAdminConfirmCount[confirmTransactionId].add(1);
        }
        if(adminType[msg.sender] == uint8(AdminType.Commmon)) {
            transactionAdminConfirmCount[confirmTransactionId] = transactionAdminConfirmCount[confirmTransactionId].add(1);
        }
        uint8 executeTransactionType = transactionMap[confirmTransactionId].transactionType;
        if(transactionAdminConfirmCount[confirmTransactionId]>=transactionMethodNeedAdminConfirm[executeTransactionType] && transactionSuperAdminConfirmCount[confirmTransactionId]>=transactionMethodNeedSuperAdminConfirm[executeTransactionType]) {
            executeTransaction(confirmTransactionId);
        }
        emit ConfirmTransaction(confirmTransactionId);
    }

    function executeTransaction(uint executeTransactionId) private {
        require(transactionMap[executeTransactionId].status==uint8(Status.Pending),'Repeat execute');
        transactionMap[executeTransactionId].status=uint8(Status.Executed);
        (bool success, ) = transactionMap[executeTransactionId].targetAddress.call{value: 0 ether}(transactionMap[executeTransactionId].data);
        require(success,'Execution failed');
        emit ExecuteTransaction(executeTransactionId);
    }

    function addAdmin(address admin) onlySelf public returns (bool) {
        doAddAdmin(admin);
        return true;
    }

    function doAddAdmin(address admin) private returns (bool) {
        require(admins.length <= 4,'Number of Admin Limit');
        admins.push(admin);
        adminIndex[admin] = admins.length - 1;
        adminType[admin] = uint8(AdminType.Commmon);
        return true;
    }

    function removeAdmin(address admin) onlySelf public returns (bool) {
        uint index = adminIndex[admin];
        require(index>0,"Nonexistent");
        admins[index] = admins[admins.length - 1];
        admins.pop();
        delete adminType[admin];
        return true;
    }

    function addSuperAdmin(address superAdmin) onlySelf public returns (bool) {
        return doAddSuperAdmin(superAdmin);
    }

    function doAddSuperAdmin(address superAdmin) private returns (bool) {
        require(superAdmins.length <= 3,'Number of SuperAdmin Limit');
        superAdmins.push(superAdmin);
        superAdminIndex[superAdmin] = superAdmins.length - 1;
        adminType[superAdmin] = uint8(AdminType.Super);
        return true;
    }

    function removeSuperAdmin(address superAdmin) onlySelf public returns (bool) {
        uint index = superAdminIndex[superAdmin];
        require(index>0,"Nonexistent");
        superAdmins[index] = superAdmins[superAdmins.length - 1];
        superAdmins.pop();
        delete adminType[superAdmin];
        return true;
    }

    function configTransactionType(uint8 transactionMethodId, bytes4 method, uint8 adminConfirm, uint superAdminConfirm) private {
        transactionFunctionType[method] = transactionMethodId; 
        transactionMethodNeedAdminConfirm[transactionMethodId] = adminConfirm;
        transactionMethodNeedSuperAdminConfirm[transactionMethodId] = superAdminConfirm;
    }


    constructor () {
        configTransactionType(uint8(TransactionMethod.SwitchExchange),0x92918f09,2,2);
        configTransactionType(uint8(TransactionMethod.SetProductionLimit),0x4bb6640d,2,2);
        configTransactionType(uint8(TransactionMethod.SetNextProduction),0x56cf12a0,2,2);
        configTransactionType(uint8(TransactionMethod.SetPoolDistributeProportion),0xefbd8400,2,2);
        configTransactionType(uint8(TransactionMethod.AllowSupportedAddress),0xe5d9b06e,2,2);
        configTransactionType(uint8(TransactionMethod.RemoveSupportedAddressAllow),0xadb29444,2,2);
        configTransactionType(uint8(TransactionMethod.ConfigurePoolAutoAddress),0x32e38ed5,2,2);
        configTransactionType(uint8(TransactionMethod.WithdrawToken),0x01e33667,2,2);
        configTransactionType(uint8(TransactionMethod.Distribute),0xa3a9c4fe,2,2);
        configTransactionType(uint8(TransactionMethod.SetContractOwner),0xa34d42b8,2,2);
        configTransactionType(uint8(TransactionMethod.FreezeAddress),0x51e946d5,2,1);
        configTransactionType(uint8(TransactionMethod.BurnFreezeAddressCoin),0x1ee08b69,2,2);
        configTransactionType(uint8(TransactionMethod.Mint),0x40c10f19,2,2);
        configTransactionType(uint8(TransactionMethod.ChangeAccountStakeExpirationTimestamp),0xcb8de7cc,2,2);


        configTransactionType(uint8(TransactionMethod.AddAdmin),0x70480275,0,2);
        configTransactionType(uint8(TransactionMethod.RemoveAdmin),0x1785f53c,0,2);
        configTransactionType(uint8(TransactionMethod.AddSuperAdmin),0xb3292ff0,2,1);
        configTransactionType(uint8(TransactionMethod.RemoveSuperAdmin),0x4902e4aa,2,1);


        superAdmins.push();
        doAddSuperAdmin(0x946E1e444B4de317E588750f0a0b3913fa8BCAaA);
        doAddSuperAdmin(0xa2B3510CA4aDe864Fc972a31ec4103D3E158a8c4);

        admins.push();
        doAddAdmin(0x696B1E4e3ae3f8278936ea1bc58BcB4BE38A52a9);
        doAddAdmin(0xf8FB56125dD3509A53b991fB72DD60Be0A227BDF);
        doAddAdmin(0x52d13CBbfe2bc7fEF61e830d7ff9dfbe3EC7dDDd);

    }

}