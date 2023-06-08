Some simple tests to run on Gfxr Convert to see if a code change impacts the
conversion process.

# Project Structure

A set of binary traces are stored under ./traces.
Next to each binary capture file in traces is a Json Lines conversion of it
which is considered the blessed golden reference.
If the user has other useful traces which are not shareable, they can add them
to that directory alongside a blessed conversion without checking them in.

# Running Tests
If an optimisation or a change in shared uility code was made, there should be no change to the output.
If a bug was fixed, the output should change in the expected way.
