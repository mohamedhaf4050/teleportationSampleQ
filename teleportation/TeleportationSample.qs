// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Teleportation {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;

//Teleportation Demo: 
    // Quantum teleportation provides a way of moving a quantum state from one
    // location  to another without having to move physical particle(s) along
    // with it. This is done with the help of previously shared quantum
    // entanglement between the sending and the receiving locations and
    // classical communication.



    // Sends the state of one qubit to a target qubit by using teleportation.
    // Notice that after calling Teleport, the state of `msg` is collapsed.

    //Teleport takes 2 Qubits as inputs: msg and target
    operation Teleport (msg : Qubit, target : Qubit) : Unit {
        //First, allocate 1 qubit to hold the entanglement 
        use register = Qubit();

        //Create some entanglement that we can use to send our message.
        //Using the Hadmord and CNOT Gate 
        //H: Takes the state 0 to 0 + 1 and state 1 to 0 - 1 ***
        H(register); 

        //After placing the register into a superposition 
        //We apply a the register and target to a CNOT gate
        //CNOT flips the value of the target qubit if the register is 1 (like XOR gate)
        //These two operations together enables us to create entanglement 
        //between the register and target qubits
        CNOT(register, target);

        //Now we Load the message into the entangled pair.
        CNOT(msg, register);
        H(msg);

        // Measure the qubits to extract the classical data we need to
        // decode the message by applying the corrections on
        // the target qubit accordingly.
        if (MResetZ(msg) == One) { Z(target); }
        if (IsResultOne(MResetZ(register))) { X(target); }
    }
    

    // Uses teleportation to send a classical message from one qubit to another.
    // # Input
    // ## message
    // If `true`, the source qubit (`here`) is prepared in the |1〉 state, 
    //Otherwise the source qubit is prepared in |0〉.
    //
    // ## Output*********
    // The result of a Z-basis measurement on the teleported qubit,
    // represented as a Bool.
    operation TeleportClassicalMessage (message : Bool) : Bool {
        //Allocate 2 registers to store quantum information initially assigned to state 0
        //We have allocated 2 Qubits msg, target
        use (msg, target) = (Qubit(), Qubit());

        //Encode the message we want to send into the msg qubit by applying X operation.
        //It's like a NOT in classical logic 
        if (message) {
            X(msg);
        }

        // To teleport the message use the teleport operation we defined above.
        Teleport(msg, target);

        // Check what message was sent.
        return MResetZ(target) == One;
    }

    // One can also use quantum teleportation to send any quantum state
    // without losing any information. The following sample shows
    // how a randomly picked non-trivial state (|-> or |+>)
    // gets moved from one qubit to another.

    /// # Summary
    /// Uses teleportation to send a randomly picked |-> or |+> state
    /// to another.
    operation TeleportRandomMessage () : Unit {
        // Ask for some qubits that we can use to teleport.
        use (msg, target) = (Qubit(), Qubit());
        PrepareRandomMessage(msg);

        // Use the operation we defined above.
        Teleport(msg, target);

        // Report message received:
        if (MeasureIsPlus(target))  { Message("Received |+>"); }
        if (MeasureIsMinus(target)) { Message("Received |->"); }

        // Reset all of the qubits that we used before releasing
        // them.
        Reset(msg);
        Reset(target);
    }
}

// ////////////////////////////////////////////////////////////////////////
// Other teleportation scenarios not illustrated here
// ////////////////////////////////////////////////////////////////////////

// ● Teleport a rotation. Rotate a basis state by a certain angle φ ∈ [0, 2π),
// for example by preparing Rₓ(φ) |0〉, and teleport the rotated state to the target qubit.
// When successful, the target qubit captures the angle φ [although, on course one does
// not have classical access to its value].
// ● "Super dense coding".  Given an EPR state |β〉 shared between the source and target
// qubits, the source can encode two classical bits a,b by applying Z^b X^a to its half
// of |β〉. Both bits can be recovered on the target by measurement in the Bell basis.
// For details refer to discussion and code in Unit Testing Sample, in file SuperdenseCoding.qs.
// ////////////////////////////////////////////////////////////////////////


