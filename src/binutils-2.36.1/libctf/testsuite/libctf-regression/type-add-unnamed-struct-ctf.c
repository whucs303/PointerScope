struct foo
{
  union
  {
    struct
    {
      int bar;
    };
  };
  union
  {
    struct
    {
      int baz;
    };
  };
};

struct foo *bar;
