"""
@title Dapp Registrar
@license MIT
@dev log dapp's user stats to help the dapp's devs
     to analyze their dapp's statistics
"""

event Persona: id: String[10]
event Message: id: String[100]

@external
def registerPersona(_id: String[10]):
    assert len(_id) <= 10
    log Persona(_id)

@external
def registerMessage(_msg: String[100]):
    assert len(_msg) <= 100
    log Message(_msg)