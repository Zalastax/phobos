/**
 * Copyright: Copyright (c) 2011-2013 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.object_;

version (unittest):
private:

import std.serialization.serializer;
import std.serialization.archivers.xmlarchiver;
import std.serialization.tests.util;
import std.traits;

alias Archiver = XmlArchiver!();
Archiver archive;
Serializer!(Archiver) serializer;

class A
{
    override equals_t opEquals (Object other)
    {
        if (auto o = cast(A) other)
            return true;

        return false;
    }
}

A a;

void beforeEach ()
{
    import std.array : appender;

    archive = new Archiver(appender!(string)());
    serializer = Serializer(archive);

    a = new A;

    serializer.serialize(a);
}

@describe("serialize object")
{
    @it("should return a serialized object") unittest
    {
        beforeEach();

        assert(archive.data().containsDefaultXmlContent());
        assert(archive.data().containsXmlTag("object", `runtimeType="` ~ typeid(A).toString() ~ `" type="` ~ fullyQualifiedName!(A) ~ `" key="0" id="0"`, true));
    }
}

@describe("deserialize object")
{
    @it("should return a deserialized object equal to the original object") unittest
    {
        beforeEach();

        auto aDeserialized = serializer.deserialize!(A)(archive.untypedData);
        assert(a == aDeserialized);
    }
}