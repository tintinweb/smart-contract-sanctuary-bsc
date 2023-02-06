// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/ERC20.sol';
import 'Farmable/Farmable.sol';
import 'GentleMidnight/GentleMidnight.sol';
import 'Tangle/vars/minBal.sol';
import 'Tangle/vars/airdropAmount.sol';
import 'Tangle/vars/owner.sol';
import 'Tangle/exts/setLiquidity.sol';
import 'Tangle/exts/setMinBal.sol';
import 'Tangle/exts/setAirdropAmount.sol';
import 'Tangle/exts/update.sol';
import 'Tangle/exts/root.sol';
import 'Tangle/events/Deploy.sol';

contract Tangle is
ERC20,
Farmable,
GentleMidnight,
hasExtSetLiquidity,
hasExtSetMinBal,
hasExtSetAirdropAmount,
hasExtUpdate,
hasExtRoot,
hasEventDeploy
{

    constructor()
    {
        // ERC20 init
        name = "Tangle";
        symbol = "TNGL";
        decimals = 9;
        totalSupply = 1e9 * 10 ** decimals;
        // Farmable init
        generator.C = 14016000;
        generator.Tp = block.timestamp;
        generator.Tc = block.timestamp;
        generator.D = 100;
        generator.S = 1e32;
        farms['hold'].N = 4;
        farms['airdrop'].N = 10;
        farms['stake'].N = 32;
        farms['GentleMidnight'].N = 52;
        // Tangle init
        owner = msg.sender;
        minBal = 1;
        airdropAmount = 1e9;
        uint initSupply = totalSupply / 10;
        move(address(this), balanceOf, generator, farms, accounts, minBal, [address(0), msg.sender], initSupply);
        move(address(this), balanceOf, generator, farms, accounts, minBal, [address(0), address(this)], totalSupply - initSupply);
        emit Transfer(address(0), address(this), totalSupply - initSupply);
        emit Transfer(address(0), msg.sender, initSupply);
        emit Deploy();
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/exts/approve.sol';
import 'ERC20/exts/transfer.sol';
import 'ERC20/exts/transferFrom.sol';
import 'ERC20/vars/decimals.sol';
import 'ERC20/vars/name.sol';
import 'ERC20/vars/symbol.sol';
import 'ERC20/vars/totalSupply.sol';

contract ERC20 is
hasExtApprove,
hasExtTransfer,
hasExtTransferFrom,
hasVarDecimals,
hasVarName,
hasVarSymbol,
hasVarTotalSupply
{}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/exts/adjustStake.sol';
import 'Farmable/exts/airdrop.sol';
import 'Farmable/exts/available.sol';
import 'Farmable/exts/claim.sol';

contract Farmable is
hasExtAdjustStake,
hasExtAirdrop,
hasExtAvailable,
hasExtClaim
{}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/exts/exchange.sol';
import 'GentleMidnight/exts/execute.sol';

contract GentleMidnight is
hasExtExchange,
hasExtExecute
{}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarMinBal {

    uint public minBal;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarAirdropAmount {

    uint public airdropAmount;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarOwner {

    address public owner;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/vars/liquidity.sol';
import 'Tangle/mods/isOwner.sol';
import 'Tangle/events/SetLiquidity.sol';

contract hasExtSetLiquidity is
hasVarLiquidity,
hasModIsOwner,
hasEventSetLiquidity
{
    function setLiquidity(address _liquidity) external isOwner
    {
        liquidity = ERC20(_liquidity);
        emit SetLiquidity(_liquidity);
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Tangle/vars/minBal.sol';
import 'Tangle/mods/isOwner.sol';
import 'Tangle/events/SetMinBal.sol';

contract hasExtSetMinBal is
hasVarMinBal,
hasModIsOwner,
hasEventSetMinBal
{
    function setMinBal(uint _minBal) external isOwner
    {
        minBal = _minBal;
        emit SetMinBal(_minBal);
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Tangle/vars/airdropAmount.sol';
import 'Tangle/mods/isOwner.sol';
import 'Tangle/events/SetAirdropAmount.sol';

contract hasExtSetAirdropAmount is
hasVarAirdropAmount,
hasModIsOwner,
hasEventSetAirdropAmount
{
    function setAirdropAmount(uint _airdropAmount) external isOwner
    {
        airdropAmount = _airdropAmount;
        emit SetAirdropAmount(_airdropAmount);
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasExtUpdate
{
    function update() external payable {}
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/vars/ADISA.sol';

contract hasExtRoot is
hasVarADISA
{
    function root(uint i) external view returns (bytes32)
    {
        return adisa.roots[i];
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventDeploy {

    event Deploy();

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/vars/allowance.sol';
import 'ERC20/events/Approval.sol';

contract hasExtApprove is
hasEventApproval,
hasVarAllowance
{

    function approve(
        address spender, 
        uint value
    ) external {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/events/Transfer.sol';
import 'ERC20/ints/move.sol';
import 'ERC20/vars/balanceOf.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';
import 'Farmable/vars/liquidity.sol';
import 'Tangle/vars/minBal.sol';
import 'Tangle/vars/owner.sol';

contract hasExtTransfer is
hasEventTransfer,
hasVarBalanceOf,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarLiquidity,
hasVarMinBal,
hasVarOwner
{

    function transfer(address to, uint value) external {
        move(address(this), balanceOf, generator, farms, accounts, minBal, [msg.sender, to], value);
        emit Transfer(msg.sender, to, value);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/events/Transfer.sol';
import 'ERC20/ints/move.sol';
import 'ERC20/vars/allowance.sol';
import 'ERC20/vars/balanceOf.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';
import 'Farmable/vars/liquidity.sol';
import 'Tangle/vars/minBal.sol';
import 'Tangle/vars/owner.sol';

contract hasExtTransferFrom is
hasEventTransfer,
hasVarAllowance,
hasVarBalanceOf,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarLiquidity,
hasVarMinBal,
hasVarOwner
{

    function transferFrom(
        address from, 
        address to, 
        uint value
    ) external {
        allowance[from][msg.sender] -= value;
        move(address(this), balanceOf, generator, farms, accounts, minBal, [from, to], value);
        emit Transfer(from, to, value);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarDecimals {

    uint public decimals;
    
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarName {

    string public name;
    
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarSymbol {

    string public symbol;
    
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarTotalSupply {

    uint public totalSupply;
    
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/adjustPoints.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';
import 'Farmable/vars/liquidity.sol';
import 'Farmable/events/AdjustStake.sol';

contract hasExtAdjustStake is
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarLiquidity,
hasEventAdjustStake
{

    function adjustStake(int amount) external {
        adjustPoints(generator, farms['stake'], accounts['stake'][msg.sender], amount);
        if (amount < 0) liquidity.transfer(msg.sender, uint(-amount));
        else liquidity.transferFrom(msg.sender, address(this), uint(amount));
        emit AdjustStake(msg.sender, amount);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/events/Transfer.sol';
import 'ERC20/ints/move.sol';
import 'ERC20/vars/balanceOf.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/liquidity.sol';
import 'Farmable/events/Airdrop.sol';
import 'Tangle/vars/minBal.sol';
import 'Tangle/vars/airdropAmount.sol';
import 'Tangle/vars/owner.sol';

import 'Farmable/ints/adjustPoints.sol';
import 'Farmable/vars/generator.sol';

contract hasExtAirdrop is
hasEventTransfer,
hasVarBalanceOf,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarLiquidity,
hasVarAirdropAmount,
hasVarMinBal,
hasVarOwner,
hasEventAirdrop
{

    function airdrop(address[] calldata recipients)
    external
    {
        for (uint i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            if (balanceOf[recipient] != 0) continue;
            adjustPoints(generator, farms['airdrop'], accounts['airdrop'][msg.sender], 1);
            move(address(this), balanceOf, generator, farms, accounts, minBal, [msg.sender, recipient], airdropAmount);
        }
        emit Airdrop(msg.sender, recipients);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/available.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';

contract hasExtAvailable is
hasVarAccounts,
hasVarFarms,
hasVarGenerator
{

    function available(string[] calldata farmNames)
    external view returns (uint[] memory foo, uint _now)
    {
        _now = block.timestamp;
        foo = new uint[](farmNames.length);
        for (uint i; i < foo.length; i++) 
            foo[i] = _available(generator, farms[farmNames[i]], accounts[farmNames[i]][msg.sender]);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/vars/balanceOf.sol';
import 'ERC20/ints/move.sol';
import 'Farmable/vars/liquidity.sol';
import 'Tangle/vars/minBal.sol';
import 'Tangle/vars/owner.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';
import 'Farmable/ints/available.sol';
import 'Farmable/events/Claim.sol';

contract hasExtClaim is
hasVarBalanceOf,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarLiquidity,
hasVarMinBal,
hasVarOwner,
hasEventClaim
{

    function claim(string[] calldata farmNames) external {
        for (uint i; i < farmNames.length; i++) {
            Account storage account = accounts[farmNames[i]][msg.sender];
            Farm storage farm = farms[farmNames[i]];
            updateFarm(generator, farm);
            uint available = _available(generator, farm, account);
            move(address(this), balanceOf, generator, farms, accounts, minBal, [address(this), msg.sender], available);
            account.S = farm.S;
            account.R = 0;
        }
        emit Claim(msg.sender, farmNames);
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/events/Exchange.sol';
import 'ERC20/ints/move.sol';
import 'ERC20/vars/balanceOf.sol';
import 'Farmable/ints/adjustGenerator.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';
import 'Tangle/vars/minBal.sol';
import 'GentleMidnight/ints/insert.sol';
import 'GentleMidnight/structs/Input.sol';
import 'GentleMidnight/vars/ADISA.sol';
import 'GentleMidnight/mods/nonzeroWork.sol';

contract hasExtExchange is
hasEventExchange,
hasVarBalanceOf,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarADISA,
hasVarMinBal,
hasModNonzeroWork
{
    function exchange(uint work, Request[] calldata requests, uint gas) external payable nonzeroWork(work)
    {
        move(address(this), balanceOf, generator, farms, accounts, minBal, [msg.sender, address(this)], gas);
        Input memory input = Input(work, requests, msg.sender, msg.value, gas, adisa.count++);
        insert(adisa, input);
        emit Exchange(input);
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/adjustPoints.sol';
import 'Farmable/vars/accounts.sol';
import 'Farmable/vars/farms.sol';
import 'Farmable/vars/generator.sol';

import 'GentleMidnight/ints/stos.sol';
import 'GentleMidnight/mods/inputsOpen.sol';
import 'GentleMidnight/vars/chunks.sol';
import 'GentleMidnight/mods/inputsVerified.sol';
import 'GentleMidnight/vars/ADISA.sol';
import 'GentleMidnight/mods/workchainIntact.sol';
import 'GentleMidnight/mods/workSufficient.sol';
import 'GentleMidnight/mods/followsFirstLaw.sol';
import 'GentleMidnight/mods/inputsDistinct.sol';
import 'GentleMidnight/ints/processRollovers.sol';
import 'GentleMidnight/ints/processOutputs.sol';
import 'GentleMidnight/ints/markInputs.sol';
import 'GentleMidnight/ints/getExecutor.sol';
import 'GentleMidnight/ints/gas.sol';
import 'GentleMidnight/ints/work.sol';
import 'GentleMidnight/ints/score.sol';
import 'GentleMidnight/events/Exchange.sol';
import 'GentleMidnight/events/Mark.sol';
import 'GentleMidnight/events/Execute.sol';

contract hasExtExecute is
hasEventExchange,
hasEventMark,
hasEventExecute,
hasModInputsOpen,
hasModInputsDistinct,
hasModInputsVerified,
hasModWorkchainIntact,
hasModWorkSufficient,
hasModFollowsFirstLaw,
hasVarAccounts,
hasVarFarms,
hasVarGenerator,
hasVarADISA,
hasVarChunks
{
    function execute(
        Stream[] calldata streams, 
        Work[] calldata works, 
        Proof[] calldata proofs
    ) external
    inputsOpen(stos(streams).inputs, chunks)
    inputsDistinct(stos(streams).inputs)
    inputsVerified(stos(streams).inputs, stos(streams).proofs, adisa)
    workchainIntact(works, streams, proofs)
    workSufficient(works, stos(streams).inputs)
    followsFirstLaw(stos(streams).inputs, stos(streams).outputs, stos(streams).rollovers)
    {
        Stream calldata stream = stos(streams);
        Input[] calldata inputs = stream.inputs;
        for (uint i; i < inputs.length; i++) emit Mark(inputs[i]);
        Input[] memory newInputs = processRollovers(stream.rollovers, inputs, adisa);
        for (uint i; i < newInputs.length; i++) emit Exchange(newInputs[i]);
        processOutputs(stream.outputs);
        markInputs(inputs, chunks);
        Farm storage farm = farms['GentleMidnight'];
        (uint e_worksLength, address executor) = getExecutor(works, max(inputs));
        Work[] memory e_works = new Work[](e_worksLength); 
        for (uint i; i < e_worksLength; i++) e_works[i] = works[i];
        for (uint i; i < e_worksLength; i++) {
            address worker = works[i].worker;
            adjustPoints(generator, farm, accounts['GentleMidnight'][worker], int(score(e_works, worker) * gas(inputs) / work(inputs)));
            payable(worker).transfer(sum(stream.outputs) * 1 * 1 * score(e_works, worker) / score(e_works) / 20 / 4);
        }
        adjustPoints(generator, farm, accounts['GentleMidnight'][executor], int(score(e_works) * 3 * gas(inputs) / work(inputs)));
        payable(executor).transfer(sum(stream.outputs) * 3 * 1 / 20 / 4);
        emit Execute(msg.sender, streams, works, proofs);
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'ERC20/ERC20.sol';

contract hasVarLiquidity {

    ERC20 public liquidity;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Tangle/vars/owner.sol';

contract hasModIsOwner is
hasVarOwner
{

    modifier isOwner() {
        require(msg.sender == owner, 'not owner');
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventSetLiquidity {

    event SetLiquidity(address liquidity);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventSetMinBal {

    event SetMinBal(uint minBal);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventSetAirdropAmount {

    event SetAirdropAmount(uint airdropAmount);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/ADISA.sol';

contract hasVarADISA {

    ADISA public adisa;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarAllowance {

    mapping(address => mapping(address => uint)) public allowance;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventApproval {

    event Approval(
        address owner, 
        address spender, 
        uint value
    );

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventTransfer {

    event Transfer(
        address from, 
        address to, 
        uint value
    );

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/adjustGenerator.sol';
import 'Farmable/ints/adjustPoints.sol';

function move(
    address _this,
    mapping(address => uint) storage balances,
    Generator storage generator,
    mapping(string => Farm) storage farms,
    mapping(string => mapping(address => Account)) storage accounts,
    uint minBal,
    address[2] memory path, 
    uint value
) {
    if (path[0] != address(0) && balances[path[0]] - value < minBal) value -= minBal;
    for (uint i = 0; i < 2; i++)
        if (path[i].code.length == 0 && path[i] != address(0) && path[i] != _this)
            adjustPoints(generator, farms['hold'], accounts['hold'][path[i]], (2 * int(i) - 1) * int(value));
    if (path[0] != address(0)) balances[path[0]] -= value;
    balances[path[1]] += value;
    if (path[1] == _this) adjustGenerator(generator, value);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarBalanceOf {

    mapping(address => uint) public balanceOf;
    
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Account.sol';

contract hasVarAccounts {

    mapping(string => mapping(address => Account)) public accounts;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Farm.sol';

contract hasVarFarms {

    mapping(string => Farm) public farms;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Generator.sol';

contract hasVarGenerator {

    Generator public generator;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/updateFarm.sol';
import 'Farmable/ints/updateAccount.sol';

function adjustPoints(
    Generator storage generator,
    Farm storage farm,
    Account storage account,
    int amount
) {
    updateFarm(generator, farm);
    updateAccount(generator, farm, account);
    farm.P = uint(int(farm.P) + amount);
    account.P = uint(int(account.P) + amount);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventAdjustStake {

    event AdjustStake(address staker, int amount);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventAirdrop {

    event Airdrop(
        address airdropper, 
        address[] recipients
    );

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Account.sol';
import 'Farmable/structs/Farm.sol';
import 'Farmable/ints/generated.sol';

function _available(
    Generator storage generator,
    Farm storage farm,
    Account storage account 
) view returns (uint) {
    if (farm.P == 0) return 0;
    uint R = farm.N * generated(generator) / generator.D;
    uint S = farm.S + (R - farm.R) / farm.P;
    return account.R + account.P * (S - account.S) / generator.S;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasEventClaim {

    event Claim(address claimer, string[] names);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

contract hasEventExchange {

    event Exchange(Input input);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/ints/generated.sol';

function adjustGenerator(
    Generator storage generator,
    uint amount
) {
    generator.R = generated(generator) / generator.S;
    generator.Tp = generator.Tc;
    generator.Tc = block.timestamp;
    generator.C += generator.Tc - generator.Tp;
    generator.M += amount;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/ruler.sol';
import 'GentleMidnight/structs/ADISA.sol';
import 'GentleMidnight/structs/Input.sol';

function insert(
    ADISA storage adisa,
    Input memory input
) {
    uint r = ruler(input.id);
    bytes32 h = keccak256(abi.encode(input));
    for (uint i; i < r; i++) h = keccak256(abi.encode(adisa.roots[i], h));
    adisa.roots[r] = h;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Request.sol';

struct Input {
    uint work;
    Request[] requests;
    address sender;
    uint value;
    uint gas;
    uint id; 
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

contract hasModNonzeroWork
{
    modifier nonzeroWork(uint work) {
        require(work > 0, 'nonzero work');
        _;
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Stream.sol';

function stos(Stream[] calldata streams) view returns (Stream calldata stream) {
    stream = streams[0];
    for (uint i; i < streams.length; i++) if (streams[i].chain == block.chainid) return streams[i];
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

contract hasModInputsOpen
{
    modifier inputsOpen(
        Input[] calldata inputs,
        mapping(uint => uint) storage chunks
    ) {
        for (uint i; i < inputs.length; i++) require(chunks[inputs[i].id / 256] & 1 << inputs[i].id % 256 == 0, 'input closed');
        _;
    }
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

contract hasVarChunks {

    mapping (uint => uint) public chunks;

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/verify.sol';
import 'GentleMidnight/structs/ADISA.sol';

contract hasModInputsVerified {

    modifier inputsVerified (
        Input[] calldata inputs,
        Proof[] calldata proofs,
        ADISA storage adisa
    ) {
        for (uint i; i < inputs.length; i++) require(verify(inputs[i], proofs[i], adisa), 'input unverified');
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/verify.sol';
import 'GentleMidnight/structs/Proof.sol';
import 'GentleMidnight/structs/Stream.sol';
import 'GentleMidnight/structs/Work.sol';

contract hasModWorkchainIntact {

    modifier workchainIntact (
        Work[] calldata works, 
        Stream[] calldata streams, 
        Proof[] calldata proofs
    ) {
        for (uint i; i < works.length; i++) {
            Work calldata work = works[i];
            require(verify(keccak256(i == 0 ? abi.encode(streams) : abi.encode(works[i - 1])), proofs[i], work.root), 'workchain broken');
        }
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/score.sol';
import 'GentleMidnight/ints/max.sol';

contract hasModWorkSufficient {

    modifier workSufficient (
        Work[] calldata works,
        Input[] calldata inputs
    ) {
        require(score(works) >= max(inputs), 'work insufficient');
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/sum.sol';

contract hasModFollowsFirstLaw {

    modifier followsFirstLaw(
        Input[] calldata inputs,
        Output[] calldata outputs,
        Rollover[] calldata rollovers
    ) {
        require(sum(inputs) == sum(outputs) + sum(rollovers, inputs), 'first law broken');
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

contract hasModInputsDistinct {

    modifier inputsDistinct(Input[] calldata inputs)
    {
        for (uint i; i < inputs.length; i++)
            for (uint j = i + 1; j < inputs.length; j++)
                require(inputs[i].id != inputs[j].id, 'indistinct inputs');
        _;
    }

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Rollover.sol';
import 'GentleMidnight/structs/Input.sol';
import 'GentleMidnight/ints/insert.sol';

function processRollovers(
    Rollover[] calldata rollovers,
    Input[] calldata inputs,
    ADISA storage adisa
) returns (Input[] memory) {
    Input[] memory newInputs = new Input[](rollovers.length);
    for (uint i; i < rollovers.length; i++) {
        Rollover calldata rollover = rollovers[i];
        Modifier calldata inMod = rollover.inMod;
        Input calldata input = inputs[inMod.index];
        Modifier[] calldata reqMods = rollover.reqMods;
        Request[] memory requests = new Request[](reqMods.length);
        for (uint j; j < reqMods.length; j++) {
            Modifier calldata reqMod = reqMods[j];
            Request calldata request = input.requests[reqMod.index];
            requests[j] = Request(request.chain, request.value - reqMod.subtrahend);
        }
        Input memory newInput = Input(input.work, requests, input.sender, input.value - inMod.subtrahend, input.gas, adisa.count++);
        newInputs[i] = newInput;
        insert(adisa, newInput);
    }
    return newInputs;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Output.sol';

function processOutputs(Output[] calldata outputs) {
    for (uint i; i < outputs.length; i++) payable(outputs[i].recipient).transfer(outputs[i].value * 19 / 20);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

function markInputs(
    Input[] calldata inputs,
    mapping(uint => uint) storage chunks
) {
    for (uint i; i < inputs.length; i++) chunks[inputs[i].id / 256] |= 1 << inputs[i].id % 256;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Work.sol';
import 'GentleMidnight/ints/score.sol';

function getExecutor(
    Work[] calldata works,
    uint max
) pure returns (uint, address) {
    uint sum;
    for (uint i; i < works.length; i++) {
        sum += score(keccak256(abi.encode(works[i])));
        if (sum >= max) return (i + 1, works[i].worker);
    }
    return (0, address(0));
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

function gas(Input[] memory inputs) pure returns (uint x) {
    for (uint i; i < inputs.length; i++) x += inputs[i].gas;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

function work(Input[] memory inputs) pure returns (uint x) {
    for (uint i; i < inputs.length; i++) x += inputs[i].work;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/log2.sol';
import 'GentleMidnight/structs/Work.sol';

function score(bytes32 h) pure returns (uint) {
    return 1 << 255 - log2(uint(h));
}

function score(Work[] memory works) pure returns (uint sum) {
    for (uint i; i < works.length; i++) sum += score(keccak256(abi.encode(works[i])));
}

function score(Work[] memory works, address worker) pure returns (uint sum) {
    for (uint i; i < works.length; i++) if (works[i].worker == worker) sum += score(keccak256(abi.encode(works[i])));
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

contract hasEventMark {

    event Mark(Input input);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Stream.sol';
import 'GentleMidnight/structs/Work.sol';

contract hasEventExecute {

    event Execute(address executor, Stream[] stream, Work[] works, Proof[] proofs);

}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct ADISA {
    uint count;
    mapping(uint => bytes32) roots;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Account {
    uint R;
    uint P;
    uint S;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Farm {
    uint S;
    uint P;
    uint N;
    uint R;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Generator {
    uint M;
    uint C;
    uint R;
    uint Tp;
    uint Tc;
    uint D;
    uint S;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Farm.sol';
import 'Farmable/ints/generated.sol';

function updateFarm(
    Generator storage generator,
    Farm storage farm    
) {
    if (farm.P == 0) return;
    uint R = farm.N * generated(generator) / generator.D;
    farm.S += (R - farm.R) / farm.P;
    farm.R = R;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Account.sol';
import 'Farmable/structs/Farm.sol';
import 'Farmable/structs/Generator.sol';

function updateAccount(
    Generator storage generator,
    Farm storage farm,
    Account storage account    
) {
    account.R += account.P * (farm.S - account.S) / generator.S;
    account.S = farm.S;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'Farmable/structs/Generator.sol';

function generated(
    Generator storage self
) view returns (uint) {
    uint M = self.M;
    uint C = self.C;
    uint R = self.R;
    uint Tp = self.Tp;
    uint Tc = self.Tc;
    uint t = block.timestamp;
    uint g = M-(C+Tc-Tp)*(M-R)/(t+C-Tp);
    return g * self.S;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/ints/log2.sol';

function ruler(uint x) pure returns (uint) {
    return log2(x ^ x + 1);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Request {
    uint chain;
    uint value;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';
import 'GentleMidnight/structs/Output.sol';
import 'GentleMidnight/structs/Rollover.sol';
import 'GentleMidnight/structs/Proof.sol';

struct Stream {
    Input[] inputs;
    Proof[] proofs;
    Output[] outputs;
    Rollover[] rollovers;
    uint chain;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Proof.sol';
import 'GentleMidnight/structs/Input.sol';
import 'GentleMidnight/structs/ADISA.sol';

function verify(
    bytes32 n,
    Proof calldata proof,
    bytes32 root
) pure returns (bool) {
    bytes32[] calldata hashes = proof.hashes;
    uint i = proof.index;
    while (hashes.length > 0) {
        bytes32 m = hashes[0];
        if (i % 2 == 1) (n, m) = (m, n);
        n = keccak256(abi.encode(n, m));
        i /= 2;
        hashes = hashes[1:];
    }
    return n == root;
}

function verify(
    Input calldata input,
    Proof calldata proof,
    ADISA storage adisa
) view returns (bool) {
    return verify(keccak256(abi.encode(input)), proof, adisa.roots[proof.subtree]);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Proof {
    bytes32[] hashes;
    uint index;
    uint subtree;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Proof.sol';

struct Work {
    bytes32 root;
    address worker;
    uint n;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';

function max(Input[] calldata inputs) pure returns (uint work) {
    for (uint i; i < inputs.length; i++)
        if (inputs[i].work > work)
            work = inputs[i].work;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Input.sol';
import 'GentleMidnight/structs/Output.sol';
import 'GentleMidnight/structs/Rollover.sol';

function sum(Input[] memory inputs) pure returns (uint x) {
    for (uint i; i < inputs.length; i++) x += inputs[i].value;
}

function sum(Output[] memory outputs) pure returns (uint x) {
    for (uint i; i < outputs.length; i++) x += outputs[i].value;
}

function sum(
    Rollover[] memory rollovers,
    Input[] memory inputs
) pure returns (uint x) {
    for (uint i; i < rollovers.length; i++) x += inputs[rollovers[i].inMod.index].value - rollovers[i].inMod.subtrahend;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import 'GentleMidnight/structs/Modifier.sol';

struct Rollover {
    Modifier inMod;
    Modifier[] reqMods;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Output {
    address recipient;
    uint value;
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

function log2(uint x) pure returns (uint) {
    for (uint i; i < 8; i++) x |= x >> (1 << i);
    unchecked { x = x * 0xFF7E7D7C7B7A79787767574737271706D6C6A6968665646261605514941211 >> 248; }
    return uint8(bytes(
        hex'00D201EDD37F02F6EED4CAA8804403FBF7EFC2DFD5CB77BDA9918161452504FC'
        hex'F3F8BAF0E5C36FE8E0D6B2CCA0783CC6BEAEAA9A9282677262524636261605FD'
        hex'EBF4A6F9DDBB5FF1E3E69EC4987034E9DBE196D9D7B357CDB5A18979593D1DCF'
        hex'C7BF8EB7AFAB4FA39B93868B83682C7B736B635B534B473F372F271F170F06FE'
        hex'D1EC7EF5C9A743FAC1DE76BC906024F2B9E46EE7B19F3BC5AD996671513515EA'
        hex'A5DC5EE29D9733DA95D856B488581CCE8DB64EA2858A2B7A6A5A4A3E2E1E0ED0'
        hex'7DC842C0758F23B86DB03AAC655014A45D9C329455871B8C4D842A69492D0D7C'
        hex'4174226C3964135C31541A4C29480C402138123019280B2011180A10090807FF'
    )[x]);
}

// SPDX-FileCopyrightText: © 2023 BRAD BROWN, LLC <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

struct Modifier {
    uint index;
    uint subtrahend;
}